#!/usr/bin/env perl

=head1 NAME 
                                                                       
 script.pl - 

=head1 SYNOPSIS    

 script.pl -i file -o file

=head1 DESCRIPTION
                                                                   
 ...

=head1 AUTHOR 

S. Evan Staton                                                

=head1 CONTACT
 
statonse at gmail dot com

=head1 REQUIRED ARGUMENTS

=over 2

=item -i, --infile

The file ...

=item -o, --outfile

A file to place the ...

=back

=head1 OPTIONS

=over 2

=item -h, --help

Print a usage statement. 

=item -m, --man

Print the full documentation.

=cut      

use 5.010;
use strict;
use warnings;
use autodie;
use File::Basename;
use File::Find;
use File::Copy;
use Try::Tiny;
use Capture::Tiny       qw(capture);
use IPC::System::Simple qw(system);
use Time::HiRes         qw(gettimeofday);
use Getopt::Long;
use Pod::Usage;
use Data::Dump;

my $infile;
my $outfile;
my $help;
my $man;

GetOptions('i|infile=s'   => \$infile,
	   'o|outfile=s'  => \$outfile,
	   'h|help'       => \$help,
	   'm|man'        => \$man,
	   );

pod2usage( -verbose => 2 ) if $man;

usage() and exit(0) if $help;

if (!$infile || !$outfile) {
    say "\nERROR: No input was given.\n";
    usage();
    exit(1);
}

open my $in, '<', $infile or die "ERROR: Could not open file: $infile\n";
open my $out, '>', $outfile or die "\nERROR: Could not open file: $outfile\n";

# counters
my $t0 = gettimeofday();
my $fasnum = 0;
my $headchar = 0;
my $non_atgcn = 0;

my @aux = undef;
my ($name, $comm, $seq, $qual);
my ($n, $slen, $qlen) = (0, 0, 0);

while (($name, $comm, $seq, $qual) = readfq(\*$in, \@aux)) {
    $fasnum++;

}
close $in;
close $out;

my $t1 = gettimeofday();
my $elapsed = $t1 - $t0;
my $time = sprintf("%.2f",$elapsed);


exit;

sub readfq {
    my ($fh, $aux) = @_;
    @$aux = [undef, 0] if (!@$aux);
    return if ($aux->[1]);
    if (!defined($aux->[0])) {
	while (<$fh>) {
	    chomp;
	    if (substr($_, 0, 1) eq '>' || substr($_, 0, 1) eq '@') {
		$aux->[0] = $_;
		last;
	    }
	}
	if (!defined($aux->[0])) {
	    $aux->[1] = 1;
	    return;
	}
    }
    my ($name, $comm) = /^.(\S+)(?:\s+)(\S+.*)/ ? ($1, $2) : 
	                /^.(\S+)/ ? ($1, '') : ('', '');
    my $seq = '';
    my $c;
    $aux->[0] = undef;
    while (<$fh>) {
	chomp;
	$c = substr($_, 0, 1);
	last if ($c eq '>' || $c eq '@' || $c eq '+');
	$seq .= $_;
    }
    $aux->[0] = $_;
    $aux->[1] = 1 if (!defined($aux->[0]));
    return ($name, $comm, $seq) if ($c ne '+');
    my $qual = '';
    while (<$fh>) {
	chomp;
	$qual .= $_;
	if (length($qual) >= length($seq)) {
	    $aux->[0] = undef;
	    return ($name, $comm, $seq, $qual);
	}
    }
    $aux->[1] = 1;
    return ($name, $seq);
}

sub usage {
  my $script = basename($0);
  print STDERR <<END
USAGE: $script -i file -o file

Required:
    -i|infile    :    input
    -o|outfile   :    output
    
Options:
    -h|help      :    Print usage statement.
    -m|man       :    Print full documentation.
END
}
