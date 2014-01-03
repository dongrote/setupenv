#!/bin/bash

# Place this pre-commit hook into $PROJECTDIR/.git/hooks/pre-commit

if [[ `git symbolic-ref HEAD` == "refs/heads/master" ]]
 then
     echo "You cannot commit in master!"
     exit 1
fi
