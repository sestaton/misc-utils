#!/bin/bash

## Description: recursively update version number in project root
ack -l --print0 --perl --ignore-file=is:Makefile.PL 0.06 | xargs -0 sed -i 's/0.06/0.06.1/g'

## NB: Another way to do this, which is much easier, is to install Perl::Version and run the 
## 'perl-reversion' script like so:
perl-reversion -bump-subversion -dryrun

# The '-dryrun' argument above shows you what files will be changed, and what the version will be changed
# to. I always do this to be sure I'm making the change I want. If it looks right, just run the same
# command without '-dryrun' and your versions will be updated everywhere, including the documentation.
# Running 'perl-reversion' in a project root without any arguments will print the current versions.
