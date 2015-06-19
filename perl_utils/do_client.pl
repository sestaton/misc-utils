#!/usr/bin/env perl

#NB: this only works with DigitalOcean API version 1, and you must
#    have ssh keys set up.
#TODO: add better logging/timing

use 5.010;
use strict;
use warnings;
use File::Spec;
use File::Basename;
use Config::Tiny;
use DigitalOcean;
use Getopt::Long;
use UUID::Tiny ':std';
use Data::Dump;

my %opt;
GetOptions(\%opt, 'size|s=i', 
	   'region|r=i',
	   'name|n=s',
	   'image|id=i',
	   'configfile|c=s', 
	   'available|a=s',
	   'droplets',
	   'destroy',
	   'login|l');

usage() and exit(1) unless %opt;

$opt{configfile} //= File::Spec->catfile($ENV{HOME}, ".digitalocean");
#$opt{region} //= 3;        # San Francisco
#$opt{size}   //= '512MB';
#$opt{name}   //= create_uuid_as_string(UUID_V1);
#$opt{image}  //= 11836690; # Ubuntu 14.04 x64

my $config = Config::Tiny->read( $opt{configfile}, 'utf8' );
my $do_obj = DigitalOcean->new(%{ $config->{doauth} });

#my ($region_id, $size_specs);
if ($opt{available}) {
    if ($opt{available} =~ /sizes/i) {
	my $size_specs = get_sizes($do_obj);
	dd $size_specs and exit;
    }
    elsif ($opt{available} =~ /images/i) {
	my $image_specs  = get_images($do_obj);
	dd $image_specs and exit;
    }
    elsif ($opt{available} =~ /regions/i) {
	my $regions = get_regions($do_obj); 
	dd $regions and exit;
    }
    else {
	say "\nERROR: ",$opt{available}," is not recognized. ".
	    "Argument must be one of: sizes, images, or regions. Exiting.";
	exit(1);
    }
}

if ($opt{droplets}) {
    say "Running droplets: ";
    get_droplets($do_obj) and exit;
}

my $ssh_id = get_keys($do_obj);
$opt{region} //= 3;        # San Francisco
$opt{size}   //= '512MB';
$opt{name}   //= create_uuid_as_string(UUID_V1);
$opt{image}  //= 11836690; # Ubuntu 14.04 x64

my $t0 = time;
my $droplet = $do_obj->create_droplet(
    name          => $opt{name},
    size_id       => $opt{size},
    image_id      => $opt{image},
    region_id     => $opt{region},
    ssh_key_ids   => $ssh_id,
    wait_on_event => 1,
);
my $t1 = time;

#my $password = $droplet->password_reset;
#dd $password;
my $server = $do_obj->droplet($droplet->id);

#say "password ", $password;
say "---------------------------------------------------";
say "Created Droplet:         ", $server->id; 
say "Droplet name:            ", $server->name, 
say "Server IP:               ", $server->ip_address;
say "Creation time (seconds): ", $t1-$t0;
say "---------------------------------------------------";

if ($opt{login}) {
    my $cmd = sprintf 'ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@%s "uname -a; uptime; hostname"',
    $server->ip_address;
    #say $cmd;
    system $cmd == 0 or die $!;
}

if ($opt{destroy}) {
    get_droplets($do_obj);
    my $serv = $do_obj->droplet($opt{serverid});
    $server->destroy;
    say "====> After destroy...";
    get_droplets($do_obj);
}
#
# methods
#
sub get_sizes {
    my ($do_obj) = @_;
    
    #$size = uc($size);
    #my $size_id;
    my $sizes = $do_obj->sizes;
    my %size_specs;
    for my $s (@$sizes) {
	#if ($size eq $s->name) {
	    $size_specs{ $s->name }{id}   = $s->id;
	    $size_specs{ $s->name }{disk} = $s->{disk};
	    $size_specs{ $s->name }{cpu}  = $s->{cpu};
	    $size_specs{ $s->name }{cost_per_month} = $s->{cost_per_month};
	    $size_specs{ $s->name }{cost_per_hour}  = $s->{cost_per_hour};
	#}
    }
    return \%size_specs;
}

sub get_regions {
    my ($do_obj) = @_;

    my %regions;
    my $region_id;
    
    for my $r (@{ $do_obj->regions }) {
	#if ($r->name =~ /San Francisco/i) {
	    #$region_id = $r->id;
	#}
	push @{$regions{region}}, { name => $r->name, id => $r->id };
    }
    return \%regions;
}

sub get_images {
    my ($do_obj) = @_;
    
    my $image_id;
    my $images = $do_obj->images;
    my %image_specs;

    for my $img (@$images) {
	push @{$image_specs{ $img->distribution }}, 
	    { id => $img->id, name => $img->name };
    }

    return \%image_specs;
}

sub get_keys {
    my ($do_obj) = @_;

    my $ssh_id;
    for my $ssh (@{ $do_obj->ssh_keys }) {
	$ssh_id = $ssh->id;
    }
    return $ssh_id;
}

sub get_droplets {
    my ($do_obj) = @_;

    for my $droplet (@{$do_obj->droplets}) {
	if (defined $droplet) {
	    printf "Droplet %s has id %s and IP address %s\n", $droplet->name, $droplet->id, $droplet->ip_address;
	}
	else {
	    say "No running droplets.";
	}
    }
}

sub usage {
    my $script = basename($0);
  print STDERR <<END

USAGE: $script --available

Required:


Options:
    -s|size          :    The size ID requested for creating a new Droplet.
    -r|region        :    The region ID requested for creating a new Droplet.
    -n|name          :    The name for the instance (Default: a UUID string).
    -id|image        :    The image ID requested for creating a new Droplet.
    -c|configfile    :    The DigitalOcean configuration file.
    -a|available     :    Given an argument of either 'size', 'regions', or 'images', print
                          all of the available options for that choice.
    -l|login         :    If given with other options, will log on to the created Droplet.
    --droplets       :    Print all running Droplets.
    --destroy        :    Given an image ID, this option will destroy the Droplet.
    -h|help          :    Print usage statement.
    -m|man           :    Print full documentation.

END
}
