#!/bin/bash

# Script to download packages from https://repo.msys2.org/
# REF:
# https://repo.msys2.org/
# https://packages.msys2.org/


# To SKIP the first N lines:
# $ tail -n +<N+1> <filename>
# < filename, excluding first N lines. >

# To PRINT the first N lines
# $ head -N <filename>


### {{{ Variables
# File containing packages in format <packae-name>\t<package-version>
# name of the file is a folder in https://repo.msys2.org/mingw/ with packages
RECENT_PACKAGES=$1
ALL_PACKAGES_LIST="__${RECENT_PACKAGES}__all__"
DOWNLOAD_LIST="__${RECENT_PACKAGES}__to_download__"
PACKAGES_FOLDER="mingw/$RECENT_PACKAGES"
PACKAGES_ROOT_URL="https://repo.msys2.org/$PACKAGES_FOLDER"
### }}} Variables


### {{{ Validate input
if [ -z "$RECENT_PACKAGES" ]; then
  echo "ERROR: Missing argument"
  exit 1
elif [ ! -f "$RECENT_PACKAGES" ]; then
  echo "ERROR: $RECENT_PACKAGES file not found"
  exit 2
else
  echo "Downloading list of packages from $PACKAGES_ROOT_URL"
fi
### }}} Validate input


### {{{ All packages
echo -n "Get all packages... "
if [ -f "$ALL_PACKAGES_LIST" ]; then
  echo "SKIPPED  ($ALL_PACKAGES_LIST already exists)"
else
  # Process raw list of packages and save
  wget -q $PACKAGES_ROOT_URL -O - | grep -e '^<a href="' | sed 's|<a href="||;s/">.*$//' > $ALL_PACKAGES_LIST
  echo "DONE"
fi
### }}} All packages


### {{{ Packages to download
# TODO: get data directly from
#   - https://packages.msys2.org/package/?repo=ucrt64
#   - https://packages.msys2.org/package/?repo=mingw64
#   - etc.
#   This will make $RECENT_PACKAGES file obsolete
echo -n "Filter packages to download... "
if [ -f "$DOWNLOAD_LIST" ]; then
  echo "SKIPPED  ($DOWNLOAD_LIST already exists)"
else
  sed 's|\t|-|;s|+|%2B|g' < $RECENT_PACKAGES | grep -f - $ALL_PACKAGES_LIST > $DOWNLOAD_LIST
  echo "DONE"
fi
### }}} Packages to download


### {{{ Download
echo "Downloading..."
mkdir -p $PACKAGES_FOLDER
# wget -i $DOWNLOAD_LIST -P $PACKAGES_FOLDER
xargs -a $DOWNLOAD_LIST -I {package} wget -nc $PACKAGES_ROOT_URL/{package} -P $PACKAGES_FOLDER
echo "DONE"
### }}} Download
