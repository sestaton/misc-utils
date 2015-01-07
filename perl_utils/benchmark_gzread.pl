#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;
use IPC::System::Simple qw(systemx);
use Benchmark qw(:all);

my $usage  = "perl $0 vcf.gz";
my $infile = shift or die $usage;

my $count  = 5;
my $linect = 0;

cmpthese($count, {
    'shell_pipe_open' => sub {
	my $fh;
	open($fh, $infile =~ /\.gz$/? "gzip -dc $infile |" : $infile) or die $!;
	$linect++ while <$fh>;
	close $fh;
	$linect = 0;
    },
    'zcat_open' => sub {
	open my $fh, '-|', 'zcat', $infile or die $!;
	$linect++ while <$fh>;
	close $fh;
	$linect = 0;
    },
    #'wc' => sub {
    	#systemx("wc", "-l $infile");
    #},
});
