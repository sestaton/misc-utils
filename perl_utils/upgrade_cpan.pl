#!/usr/bin/env perl

## Modified from: https://gist.github.com/miyagawa/2760426

use strict;
use warnings;
use File::Find::Rule;
use JSON;

my $usage = "USAGE: upgrade-cpan.pl 5.14.2 | sort -u | cpanm\n";
my $old   = shift or die $usage;
 
my @files = File::Find::Rule->file->name('install.json')->in("$ENV{HOME}/perl5/perlbrew/perls/perl-$old/lib/site_perl/$old");
for my $file (@files) {
    my $module = parse_json($file)->{name};
    print $module, "\n" if $module;
}
 
sub parse_json {
    open my $fh, shift or die $!;
    JSON::decode_json(join '', <$fh>);
}
