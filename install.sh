#!/bin/bash

# fix permissions of hooks
chmod -R +x hooks

# create link for hooks
rm -Rf .git/hooks
ln -s ../hooks ./.git/hooks
