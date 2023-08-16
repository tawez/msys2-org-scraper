#!/bin/bash

# Script to download packages from https://repo.msys2.org/
# REF:
# https://repo.msys2.org/
# https://packages.msys2.org/


### {{{ Variables
ENV=$1
PACKAGES_FOLDER="mingw/$ENV"
RECENT_PACKAGES="$ENV.recent.packages"
RECENT_PACKAGES_URI="https://packages.msys2.org/package/?repo=$ENV"
ALL_PACKAGES="$ENV.all.packages"
ALL_PACKAGES_REPO_URI="https://repo.msys2.org/mingw/$ENV"
DOWNLOAD_PACKAGES="$ENV.download.packages"
# helpers
TMP_FILE=$(date +%s.%N)
VALID_ENV="clang32|clang64|clangarm64|mingw32|mingw64|ucrt64"
### }}} Variables


### {{{ Validate input
if ! [[ "|$VALID_ENV|" == *"|$ENV|"* ]]; then
  echo "ERROR: Missing or invalid environment"
  echo ""
  echo "USAGE:"
  echo "  $(basename $0) <environment>"
  echo "Where:"
  echo "  environment:  one of $(sed 's/|/, /g' <<< $VALID_ENV)"
  exit 1
fi
### }}} Validate input


### {{{ Scrape recent package list
echo "Scraping recent packages from $RECENT_PACKAGES_URI..."
if [ -f "$RECENT_PACKAGES" ]; then
  echo "SKIPPED  ($RECENT_PACKAGES already exists. $(head -1 $RECENT_PACKAGES))"
else
  wget -q $RECENT_PACKAGES_URI -O $TMP_FILE
  # extract last update time
  grep 'Last Update:' $TMP_FILE | sed 's|^\s*||' > $RECENT_PACKAGES
  # extract header
  grep -e '<th>' $TMP_FILE | awk 'NR %3 == 1 || NR %3 == 2' | awk 'NR%2{printf $0"";next;}1' | sed 's|^\s*<th>||;s|</th>\s*<th>|;|;s|</th>$||' >> $RECENT_PACKAGES
  # extract packages
  grep -e '<td>' $TMP_FILE | awk 'NR %3 == 1 || NR %3 == 2' | awk 'NR%2{printf $0"";next;}1' | sed 's|^.*">||;s|</a></td>\s*<td>|;|;s|</td>$||' >> $RECENT_PACKAGES
  rm $TMP_FILE
  echo "DONE  (recent packages saved to $RECENT_PACKAGES)"
fi
### }}} Scrape recent package list


### {{{ Scrape all packages list
echo "Scraping all packages from $ALL_PACKAGES_REPO_URI..."
if [ -f "$ALL_PACKAGES" ]; then
  echo "SKIPPED  ($ALL_PACKAGES already exists)"
else
  # Process raw list of packages and save
  wget -q $ALL_PACKAGES_REPO_URI -O - | grep -e '^<a href="' | sed 's|<a href="||;s/">.*$//' > $ALL_PACKAGES
  echo "DONE  (all packages saved to $ALL_PACKAGES)"
fi
### }}} Scrape all packages list


### {{{ Select packages to download
echo "Selecting packages to download..."
sed 's|;|-|;s|+|%2B|g' < $RECENT_PACKAGES | grep -f - $ALL_PACKAGES > $DOWNLOAD_PACKAGES
echo "DONE  (packages to download saved to $DOWNLOAD_PACKAGES)"
### }}} Select packages to download


### {{{ Download selected packages
echo "Downloading selected packages..."
mkdir -p $PACKAGES_FOLDER
# wget -i $DOWNLOAD_LIST -P $PACKAGES_FOLDER
xargs -a $DOWNLOAD_PACKAGES -I {package} wget -nc $ALL_PACKAGES_REPO_URI/{package} -P $PACKAGES_FOLDER
echo "DONE  (packages saved to ./$PACKAGES_FOLDER)"
### }}} Download selected packages
