#!/bin/bash

# this script will make a git repo into a subdirectory of
# another git repo

# source: http://bpeirce.me/moving-one-git-repository-into-another.html

git clone te-anno te-anno_tmp 
cd te-anno_tmp

git filter-branch -f --prune-empty --tree-filter '
 mkdir -p .transposon_annotation;
 mv * .transposon_annotation;
 mv .transposon_annotation transposon_annotation
 ' -- --all

# Any hidden files in the root of your project, such as .gitignore, will be skipped. 
# We address this issue by simply moving these files into the subdirectory manually, and committing the change.
git mv .gitignore transposon_annotation
git commit -am "Move .gitignore into subdirectory."

# Before leaving subproj_tmp, we use the git gc command to delete loose objects, etc.
git gc --aggressive

# We can now merge subproj into mainproj.
cd ../sesbio
git remote add subproj ../te-anno_tmp
git fetch subproj
git merge subproj/master

# We can now delete the remote we created, clean up, and push mainproj to it’s origin.
git remote rm subproj
git gc --aggressive
git push origin master
