#!/bin/sh

# 基础软件包清理
apt-get clean
apt-get autoremove --purge -y
rm -rf /var/lib/apt/lists/* # 清理索引文件
rm -rf /var/cache/apt/archives/* # 清理安装包残留

# 移除多余语言包 (保留中英)
find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en*' ! -name 'zh*' -exec rm -rf {} +

# 清理coredump
rm -rf /var/lib/systemd/coredump/* 2>/dev/null
rm -rf /var/lib/apport/coredump/* 2>/dev/null
rm -rf /var/crash/* 2>/dev/null

# 日志截断与归档清理
find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
find /var/log -type f \( -name "*.gz" -o -name "*.1" \) -delete

printf "Cleanup Success.\n"
df -h /
