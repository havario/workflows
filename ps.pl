#!/usr/bin/env perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Term::ANSIColor;
use constant TOP_PROCESS_COUNT => 10; # 定义要显示的进程数量

# --- 主程序 Main Execution ---
main();

sub main {
    system("clear");

    # 1. 数据采集 (Gather all data first using new function names)
    my $cpu_usage_val = cpu_usage();
    my $mem_swap_data = mem_info();
    my $disks_data    = disk_usage();
    my $processes_data= top_processes();

    # 2. 数据展示 (Display all data)
    print_header("System Overview");
    print_cpu_info($cpu_usage_val);
    print_memory_and_swap_info($mem_swap_data);
    
    print_header("Disk Filesystems");
    print_disk_info($disks_data);

    print_header("Top " . TOP_PROCESS_COUNT . " Processes (by CPU)");
    print_top_processes($processes_data);
}

# --- 数据采集函数 (Data Gathering Functions with new names) ---

sub cpu_usage {
    my $stat1 = _get_cpu_times();
    sleep(1);
    my $stat2 = _get_cpu_times();

    my $total_diff = $stat2->{total} - $stat1->{total};
    return 0 if $total_diff == 0;

    my $idle_diff = $stat2->{idle} - $stat1->{idle};
    my $usage = 100 * ($total_diff - $idle_diff) / $total_diff;
    return $usage;
}

sub _get_cpu_times {
    open(my $fh, '<', '/proc/stat') or die "Cannot open /proc/stat: $!";
    my $line = <$fh>;
    close($fh);
    my @fields = split(/\s+/, $line);
    my ($user, $nice, $system, $idle, $iowait, $irq, $softirq) = @fields[1..7];
    my $total = $user + $nice + $system + $idle + $iowait + $irq + $softirq;
    return { total => $total, idle => $idle };
}

sub mem_info {
    my %data;
    open(my $fh, '<', '/proc/meminfo') or die "Cannot open /proc/meminfo: $!";
    while (my $line = <$fh>) {
        $data{$1} = $2 if $line =~ /^(\w+):\s+(\d+)\s+kB/;
    }
    close($fh);

    # 物理内存
    my $mem_total_kb = $data{MemTotal};
    my $mem_available_kb = $data{MemAvailable} || ($data{MemFree} + $data{Buffers} + $data{Cached});
    my $mem_used_kb = $mem_total_kb - $mem_available_kb;
    
    my %result = (
        mem_percent  => ($mem_used_kb / $mem_total_kb) * 100,
        mem_used_gb  => $mem_used_kb / 1024 / 1024,
        mem_total_gb => $mem_total_kb / 1024 / 1024,
    );

    # 交换分区 (如果存在)
    if (exists $data{SwapTotal} and $data{SwapTotal} > 0) {
        my $swap_total_kb = $data{SwapTotal};
        my $swap_free_kb = $data{SwapFree};
        my $swap_used_kb = $swap_total_kb - $swap_free_kb;
        $result{swap_info} = {
            swap_percent  => $swap_total_kb > 0 ? ($swap_used_kb / $swap_total_kb) * 100 : 0,
            swap_used_gb  => $swap_used_kb / 1024 / 1024,
            swap_total_gb => $swap_total_kb / 1024 / 1024,
        };
    }
    return \%result;
}

sub disk_usage {
    # -P 参数确保长路径不换行，便于解析
    my @df_lines = `df -hP`;
    shift @df_lines; # 去掉标题行
    
    my @disks;
    foreach my $line (@df_lines) {
        # 过滤掉临时的或虚拟的文件系统
        next if $line =~ /^(tmpfs|devtmpfs|squashfs)/;
        my ($fs, $size, $used, $avail, $percent, $mount) = split(/\s+/, $line);
        
        # FIX: 在处理前，移除字符串中的 '%' 符号
        $percent =~ s/%//;

        push @disks, {
            mount   => $mount,
            percent => int($percent),
            text    => "$used / $size",
        };
    }
    return \@disks;
}

sub top_processes {
    my @ps_lines = `ps aux --sort=-%cpu`;
    shift @ps_lines; # 去掉标题行

    my @processes;
    for (my $i=0; $i < @ps_lines && $i < TOP_PROCESS_COUNT; $i++) {
        my $line = $ps_lines[$i];
        $line =~ s/^\s+//; # 去掉行首空格
        my @fields = split(/\s+/, $line, 11); # 最多分割11个字段，最后一个是COMMAND
        push @processes, {
            user    => $fields[0],
            pid     => $fields[1],
            cpu     => $fields[2],
            mem     => $fields[3],
            command => $fields[10],
        };
    }
    return \@processes;
}


# --- 数据展示函数 (Display Functions) ---

sub print_header {
    my ($title) = @_;
    print "\n", color('bold cyan'), "--- $title ---\n", color('reset');
}

sub print_bar {
    my ($label, $percent, $text_info) = @_;
    my $bar_width = 30;
    
    my $color = 'green';
    $color = 'yellow' if $percent > 70;
    $color = 'red'    if $percent > 90;
    
    my $filled = int($percent / 100 * $bar_width);
    my $bar = '[' . ('#' x $filled) . ('-' x ($bar_width - $filled)) . ']';
    
    print color("bold $color");
    printf("%-15s %s %s\n", $label, $bar, $text_info);
    print color('reset');
}

sub print_cpu_info {
    my ($usage) = @_;
    print_bar("CPU Usage", $usage, sprintf("%.2f %%", $usage));
}

sub print_memory_and_swap_info {
    my ($data) = @_;
    print_bar("Memory Usage", $data->{mem_percent}, 
              sprintf("%.2f GB / %.2f GB", $data->{mem_used_gb}, $data->{mem_total_gb}));
              
    if (exists $data->{swap_info}) {
        print_bar("Swap Usage", $data->{swap_info}->{swap_percent},
                  sprintf("%.2f GB / %.2f GB", $data->{swap_info}->{swap_used_gb}, $data->{swap_info}->{swap_total_gb}));
    }
}

sub print_disk_info {
    my ($disks) = @_;
    foreach my $disk (@$disks) {
        print_bar($disk->{mount}, $disk->{percent}, $disk->{text});
    }
}

sub print_top_processes {
    my ($processes) = @_;
    printf color('bold white') . "%-10s %-7s %-7s %-7s %s\n" . color('reset'), 
           "USER", "PID", "%CPU", "%MEM", "COMMAND";
    print "-" x 80, "\n";
    
    foreach my $p (@$processes) {
        printf "%-10s %-7s %-7s %-7s %s\n", 
               substr($p->{user}, 0, 10), 
               $p->{pid}, 
               $p->{cpu}, 
               $p->{mem}, 
               substr($p->{command}, 0, 50); # 截断过长的命令名
    }
    print "\n";
}