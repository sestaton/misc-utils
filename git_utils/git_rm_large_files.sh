#!/bin/bash

# when large files are in the commit history you cannot push changes
# to the server, they must be removed from your git history

java -jar ~/apps/bfg-1.12.7.jar --strip-blobs-bigger-than 100M tephra
cd tephra
git reflog expire --expire=now --all && git gc --prune=now --aggressive
