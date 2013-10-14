#!/usr/bin/perl
# Usage: upgrade-cpan.pl 5.14.0 | sort -u | cpanm
use strict;
use File::Find::Rule;
use JSON;
 
my $old = shift;
 
my @files = File::Find::Rule->file->name('install.json')->in("$ENV{HOME}/perl5/perlbrew/perls/perl-$old/lib/site_perl/$old");
for my $file (@files) {
    my $module = parse_json($file)->{name};
    print $module, "\n" if $module;
}
 
sub parse_json {
    open my $fh, shift or die $!;
    JSON::decode_json(join '', <$fh>);
}
