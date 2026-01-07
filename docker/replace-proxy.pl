#!/usr/bin/env perl
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 honeok <i@honeok.com>

use strict;
use warnings;

my $registry_proxy = "docker.gh-proxy.org";

my @registry_repo = (
    "docker.io",
    "registry.k8s.io",
    "k8s.gcr.io",
    "quay.io",
    "gcr.io",
    "ghcr.io",
    "mcr.microsoft.com"
);

unless (@ARGV) {
    print "Usage: $0 <File List>\n";
    exit 1;
}

$^I = "";

my $registry_regex = join("|", map { quotemeta($_) } @registry_repo);

while (<>) {
    s#(?<!\Q$registry_proxy\E/)($registry_regex)#$registry_proxy/$1#g;
    print;
}
