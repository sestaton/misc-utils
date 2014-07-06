#!/bin/bash

## This variable with allow you to ignore/skip certain tests
## like checking POD syntax. That way your install won't fail
## for annoying reasons like POD errors.

export HARNESS_SUBCLASS=TAP::Harness::Restricted