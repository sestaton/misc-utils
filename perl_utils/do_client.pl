#!/usr/bin/env perl

#NB: this only works with DigitalOcean API version 1, and you must
#    have ssh keys set up.
#TODO: add better logging/timing

use 5.010;
use strict;
use warnings;
use Config::Tiny;
use DigitalOcean;
use Data::Dump;

my $config = Config::Tiny->read( '/Users/spencerstaton/.digitalocean', 'utf8' );
my $do_obj = DigitalOcean->new(%{ $config->{doauth} });
 
my $size_id   = get_sizes($do_obj);
my $image_id  = get_images($do_obj);
my $region_id = get_regions($do_obj); 
my $ssh_id    = get_keys($do_obj);

my $t0 = time;
my $droplet = $do_obj->create_droplet(
    name          => 'demo2',
    size_id       => $size_id,
    image_id      => $image_id,
    region_id     => $region_id,
    ssh_key_ids   => $ssh_id,
    wait_on_event => 1,
);
my $t1 = time;

my $password = $droplet->password_reset;
#dd $password;
my $server = $do_obj->droplet($droplet->id);

say "password ", $password;
say "Created droplet: ",$server->id, " with name: ", $server->name, 
    " and IP: ", $server->ip_address, " in ",$t1-$t0, " seconds.";

say "Running droplets:";
get_droplets($do_obj);

my $cmd = sprintf 'ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@%s "uname -a; uptime; hostname"',
    $server->ip_address;
say $cmd;
system $cmd;
 
$server->destroy;
#
# methods
#
sub get_sizes {
    my ($do_obj) = @_;

    my $size_id;
    my $sizes = $do_obj->sizes;
    for my $s (@$sizes) {
	if ($s->name =~ /512MB/i && $s->slug =~ /512MB/i) {
	    $size_id = $s->id;
	}
    }
    return $size_id;
}

sub get_regions {
    my ($do_obj) = @_;

    my $region_id;
    for my $r (@{ $do_obj->regions }) {
	if ($r->name =~ /San Francisco/i) {
	    $region_id = $r->id;
	}
    }
    return $region_id;
}

sub get_images {
    my ($do_obj) = @_;
    
    my $image_id;
    my $images = $do_obj->images;
    for my $img (@$images) {
	if ($img->distribution =~ /ubuntu/i && $img->name =~ /14\.10\s+x64/ix) {
	    $image_id = $img->id;
	}
    }
    return $image_id;
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
	printf "Droplet %s has id %s and IP address %s\n", $droplet->name, $droplet->id, $droplet->ip_address;
    }
}
