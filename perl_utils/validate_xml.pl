#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use XML::LibXML;

my $parser = XML::LibXML->new();
$parser->validation(1);

eval { say "xml is valid=".$parser->parse_file('ch2.xml')->is_valid; };

if ($@) { say "dtd not valid: $@"; }
else    { say "dtd valid"; }
