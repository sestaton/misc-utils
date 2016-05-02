#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use File::Basename;
use XML::LibXML;

my $usage = basename($0).' file.xml';
my $xml   = shift or die $usage;

my $parser = XML::LibXML->new();
$parser->validation(1);

eval { say "xml is valid=".$parser->parse_file($xml)->is_valid; };

if ($@) { say "dtd not valid: $@"; }
else    { say "dtd valid"; }
