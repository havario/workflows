#!/usr/bin/env perl

use strict;
use warnings;

my $proxy_domain = "docker.gh-proxy.org";

my @registers = (
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

my $registry_pattern = join("|", map { quotemeta($_) } @registers);

while (<>) {
    s#(?<!\Q$proxy_domain\E/)($registry_pattern)#$proxy_domain/$1#g;
    print;
}
