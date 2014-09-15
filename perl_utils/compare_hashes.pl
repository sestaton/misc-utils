#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use autodie qw(open);
use Test::More;

my $usage = "$0 hash_from_file1 hash_from_file2\n";
my $file1 = shift or die $usage;
my $file2 = shift or die $usage;

my $hash1 = file_to_hash($file1);
my $hash2 = file_to_hash($file2);

is_deeply($hash1, $hash2, 'Both hashs contain the same keys and values');

# methods
sub file_to_hash {
    my $file = shift;

    open my $in, '<', $file;
    my %hash;

    while (<$in>) {
	chomp;
	next if /^\{|\}/;
	my ($key, $value) = split /=>/;
	$key = trim($key);
	$value = trim($value);
	$hash{$key} = $value;
    }
    close $in;

    return \%hash;
}

sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
