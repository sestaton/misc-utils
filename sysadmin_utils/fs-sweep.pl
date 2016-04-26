use 5.010;
use strict;
use warnings;
use autodie;
use File::Find;
use File::Basename;
use Number::Format;
use List::Util qw(max);

my (%files, %sizes, %dups, %seen);

my $usage   = basename($0).' topdir';
my $rootdir = shift or die $usage;

find( sub { push @{$files{$_}}, $File::Find::name if -f }, $rootdir );
find( sub { push @{$sizes{$_}}, -s if -f }, $rootdir );

for my $file (keys %files) {
    next if $file eq '.';
    if (@{$files{$file}} > 1 || @{$sizes{$file}} > 1) {
	my $size = @{$sizes{$file}}[0];
	$dups{$size} = $files{$file};
    }
}

my $date = qx(date); chomp $date;
say "===== Showing duplicate files under: $rootdir (execution time: $date) =====";
my ($total, @buffer);
my $format = Number::Format->new;
for my $dup (reverse sort { $a <=> $b } keys %dups) {
    my @names = map { basename($_) } @{$dups{$dup}};
    if (all_the_same(\@names) == 1) {
	my $ct = @{$dups{$dup}};
	$total += $dup * $ct;
	for my $file (@{$dups{$dup}}) {
	    my $str = join "\t", $file, $format->format_bytes($dup); 
	    push @buffer, length($str);
	    say $str;
	}
    }
}

my $len = max(@buffer);
say "=" x ($len/5);
my $buf = $len - 9;
printf "%-${buf}s %10s\n", "Total", $format->format_bytes($total);

sub all_the_same {
    my ($ref) = @_;
    return 1 unless @$ref;
    my $cmpv = \ $ref->[-1];
    for my $i (0 .. $#$ref - 1)  {
        my $this = \ $ref->[$i];
        return unless defined $$cmpv == defined $$this;
        return if defined $$this
            and ( $$cmpv ne $$this );
    }
    return 1;
}
