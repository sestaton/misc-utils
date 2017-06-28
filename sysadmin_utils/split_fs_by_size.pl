use 5.010;
use strict;
use warnings;
use autodie;
#use File::Find;
use File::Find::Rule;
use File::Basename;
use Number::Format;
use Sort::Naturally;
use Data::Dump::Color;

my (%files, %sizes, %dups, %seen);

my $usage   = basename($0).' rootdir name';
my $rootdir = shift or die $usage;
my $name    = shift or die $usage;

my $buckets = split_fs_into_buckets($rootdir, $name);
#dd $buckets and exit;
summarize_buckets($buckets);

exit;
#
# methods
#
sub summarize_buckets {
    my ($buckets, $name) = @_;

    my $form = Number::Format->new;

    my $total;
    for my $bucket (nsort keys %$buckets) {
	my $bname = _make_s3_bucket($bucket, $name);
	
	my $size;
	for my $hash (@{$buckets->{$bucket}}) {
	    $size += $hash->{size};

	    my @cmd = ('aws', 's3', 'cp');
	    push @cmd, '--recursive' 
		if $hash->{type} eq 'dir';
	    push @cmd, $hash->{resource};
	    push @cmd, $bname;

	    say join q{ }, 'CP: ', @cmd;
	    system(@cmd) == 0 or die $!;
	}
	say join q{ }, $bucket, $form->format_bytes($size);
	$total += $size;
    }

    say "\n", join q{ }, scalar(keys %$buckets), ' buckets have a total size of: ', $form->format_bytes($total), "\n";
}

sub split_fs_into_buckets {
    my ($rootdir) = @_;

    my $mb = 1024**2;
    my $gb = 1024**3;
    my $tb = 1024**4;

    ## Bucket size: Here 40 MB for testing. Set as needed. S3 buckets can be 5 TB.
    my $bucket_size = $mb*40;
    #
    # my $bucket_size = $tb*5;
    # my $f = Number::Format->new; 
    # say $f->format_bytes($bucket_size)
    # 5,120G

    my @dirs = File::Find::Rule
	->maxdepth( 1 )
	->name( '*' )
	->in( $rootdir );

    use File::Find;

    my ($bsize, $splitct) = (0, 1);    
    my ($bucket, %buckets);

    for my $dir (nsort @dirs) {
	next if $dir eq $rootdir;
	$bucket = $rootdir."-$splitct";
	
	if ($bsize > $bucket_size) { 
	    $splitct++;
	    $bsize = 0;
	}
	
	if (-d $dir) {
	    my $total = 0;
	    find(sub { $total += -s if -f }, $dir);
	    $bsize += $total;
	    push @{$buckets{$bucket}}, { type => 'dir', resource => $dir, size => $total };
	}
	elsif (-f $dir) {
	    my $stat = -s $dir;
	    $bsize += $stat;
	    push @{$buckets{$bucket}}, { type => 'file', resource => $dir, size => $stat };
	}
	else {
	    say "\nWARNING: $dir is something other than a file or dir";
	}  
    }

    return \%buckets;
}

sub _make_s3_bucket {
    my ($bucket, $name) = @_;

    my $bname = "s3://$name-$bucket";
    my $valid = _check_valid_bucketname($bname);
    if ($valid) {
	my @cmd = ('aws', 's3', 'mb', $bname);
	say join q{ }, 'MB: ', @cmd;
	system(@cmd) == 0 or die $!;
	return $bname;
    }
    else {
	say "\nERROR: '$bname' is not a valid bucket name. Cannot proceed. ".
	    "See: http://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html\n";
	exit(1);
    }
}

sub _check_valid_bucketname {
    my ($bucked) = @_;

    # The below checks if the bucket name is valid
    # reference: http://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html
    my $blen = length($bucket);
    if ($bucket =~ /.|_|-\z|[A-Z]/ || $blen < 3 || $blen > 63) {
	return 0;
    }
    else {
	return 1;
    }
}
