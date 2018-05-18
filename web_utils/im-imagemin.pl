#!/usr/bin/env perl

#TODO: Add debug option to show results, compression level

use 5.014;
use strict;
use warnings;
use File::Find;
use File::Spec;
use File::Basename;
use File::Path qw(make_path);
use Cwd        qw(abs_path);
use Getopt::Long;

my $usage = "\nUSAGE: ".basename($0)." -i <indir> -o <outdir>\n";
$usage .= "\n <indir>  : A directory of images to minimize for the web or other uses.
 <outdir> : The base directory to write the results.

The depth of subdirectories in the input does not matter, the exact structure will be recreated.
Note also that the exact same names are written to the output directory. This is intentional, as
it is convenient for web development to avoid editing templates.

NB: This relies on ImageMagick for the magic parts.";

my %opts;
GetOptions(\%opts, 'indir|i=s', 'outdir|o=s');
say STDERR $usage and exit(1) unless %opts;

if (-e $opts{outdir}) {
    say STDERR "\nERROR: The output directory exists. Will not overwrite, so please remove it and try again, ".
	"or change the output name.\n";
    exit(1);
}
else {
    make_path($opts{outdir}, {verbose => 0, mode => 0771,})
}

my @files;
find(sub { push @files, $File::Find::name if -f and /\.jpg$|\.png|\.gif$/ }, abs_path($opts{indir}));

$opts{indir} = abs_path($opts{indir});

for my $in (@files) {
    my ($file, $path, $suffix) = fileparse($in, qr/\.[^.]*/);
    my ($dir) = ($path =~ s/$opts{indir}//r);

    my $outpath;
    if ($dir ne '') {
	my @dirs = split /\// , $dir;
	$outpath = File::Spec->catdir(abs_path($opts{outdir}), @dirs);
    }
    else {
	$outpath = $opts{outdir};
    }

    make_path($outpath, {verbose => 0, mode => 0771,})
      unless -e $outpath;
    my $outfile = File::Spec->catfile($outpath, $file.$suffix);
    my @cmd = ('convert', '-strip', '-interlace', 'Plane', '-gaussian-blur', '0.05', '-quality', '85%', $in, $outfile);
    say join q{ }, "CMD:", @cmd;
    system(@cmd) == 0 or die $!;
}
