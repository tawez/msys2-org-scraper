#!/bin/bash

# Download the latest packages for the given env in format:
# <packae-name>\t<package-version>


### {{{ Variables
PACKAGES_ENV=$1
PACKAGES_ROOT_URI="https://packages.msys2.org/package/"
LATEST_PACKAGES_URI="$PACKAGES_ROOT_URI?repo=$PACKAGES_ENV"
PACKAGES_FILE="$PACKAGES_ENV.latest.packages"
TMP_FILE=$(date +%s.%N)
### }}} Variables


### {{{ Validate input
# TODO: validate PACKAGES_ENV value
### }}} Validate input


### {{{ Download and process latest packages
if [ -f "$PACKAGES_FILE" ]; then
  echo "SKIPPED  ($PACKAGES_FILE already exists)"
else
  echo "Download and process latest packages from $LATEST_PACKAGES_URI"
  # TODO: save PACKAGES_FILE with current date (there is a line '        Last Update: 2023-08-14 11:30:39')
  #       a) as the first line of the file (only one file)
  #       b) as a part of file name (multiple env files allowed)
  wget -q $LATEST_PACKAGES_URI -O $TMP_FILE
  grep 'Last Update:' $TMP_FILE | sed 's|^\s*|# |' > $PACKAGES_FILE
  grep -e '<th>' $TMP_FILE | awk 'NR %3 == 1 || NR %3 == 2' | awk 'NR%2{printf $0"";next;}1' | sed 's|^\s*<th>||;s|</th>\s*<th>|;|;s|</th>$||' >> $PACKAGES_FILE
  grep -e '<td>' $TMP_FILE | awk 'NR %3 == 1 || NR %3 == 2' | awk 'NR%2{printf $0"";next;}1' | sed 's|^.*">||;s|</a></td>\s*<td>|;|;s|</td>$||' >> $PACKAGES_FILE
  # wget -q $LATEST_PACKAGES_URI -O - | grep -e '<td>' | awk 'NR %3 == 1 || NR %3 == 2' | awk 'NR%2{printf $0"";next;}1' | sed 's|^.*">||;s|</a></td>\s*<td>|\t|;s|</td>$||' > "$PACKAGES_FILE"
  rm $TMP_FILE
  echo "DONE"
fi
### }}} Download and process latest packages
