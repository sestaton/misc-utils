#!/usr/bin/env perl

# source: https://github.com/perlancar/scripts/blob/master/genpasswd
use strict;
use warnings;
use Getopt::Long;

my %Opt = (
           'minlength' => 16,
           'maxlength' => 20,
           'length'    => undef,
           'num'       => 1,
    );

GetOptions(
    'minlength=i' => \$Opt{minlength},
    'maxlength=i' => \$Opt{maxlength},
    'length=i'    => \$Opt{length},
    'num=i'       => \$Opt{num},
    );

$Opt{maxlength} = $Opt{minlength} if $Opt{minlength} > $Opt{maxlength};

my @set = ('A'..'Z', 'a'..'z', '0'..'9', '_');

for (1..$Opt{num}) {
    my $len = $Opt{length} ||
	int(rand()*($Opt{maxlength}-$Opt{minlength}+1)) + $Opt{minlength};
    my $pass = join "", map { $set[rand @set] } 1..$len;
    print "$pass\n";
}
