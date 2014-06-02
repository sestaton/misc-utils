#!/bin/bash

## Description: recursively update version number in project root

ack -l --print0 --perl --ignore-file=is:Makefile.PL 0.06 | xargs -0 sed -i 's/0.06/0.06.1/g'