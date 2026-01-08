#!/usr/bin/env perl
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 honeok <i@honeok.com>

use strict;
use warnings;

my $registry_proxy = "docker.gh-proxy.org";

my @registry_repo = (
    "docker.io",
    "gcr.io",
    "ghcr.io",
    "k8s.gcr.io",
    "mcr.microsoft.com",
    "quay.io",
    "registry.k8s.io"
);

unless (@ARGV) {
    print "Usage: $0 <File List>\n";
    exit 1;
}

$^I = "";

my $registry_regex = join("|", map { quotemeta($_) } @registry_repo);

# 上下文捕获
while (<>) {
    s{
        (^\s*image:\s*|^\s*FROM\s+(?:--platform=\S+\s+)?|--from=)
        (["']?)
        ([^\s"']+)
        (["']?)
    }{
        $1 . $2 . process_image($3) . $4
    }gxe;

    print;
}

sub process_image {
    my ($img) = @_;
    my $target;

    # 如果已经是代理地址 静默跳过
    return $img if $img =~ /^\Q$registry_proxy\E/;

    # 显式域名检查
    if ($img =~ m{^([^/]+)/}) {
        my $domain = $1;
        if ($domain =~ /\.|localhost/) {
            if ($domain =~ /^($registry_regex)$/) {
                $target = "$registry_proxy/$img";
            } else {
                return $img;
            }
        }
    }

    # 处理隐式 DockerHub
    unless ($target) {
        my $canonical = $img;
        $canonical = "library/$img" unless $img =~ m{/};
        $target = "$registry_proxy/docker.io/$canonical";
    }

    # 熔断机制
    if (!defined $target || $target eq $img) {
        die "Error: Failed to proxy image '$img'.\nReason: Logic matched modification criteria but result was identical or empty.\n";
    }

    print STDERR "\xe2\x9c\x93 $img => $target\n";
    return $target;
}
