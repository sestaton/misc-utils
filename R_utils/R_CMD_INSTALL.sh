#!/bin/bash

##NB: This is for setting up a custom library for testing, for example,
##    different versions of R.

/usr/local/R/2.15.0/bin/R CMD INSTALL -l ~/apps/Rpackages/ multicore_0.1-7.tar.gz 