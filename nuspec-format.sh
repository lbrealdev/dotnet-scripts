#!/bin/bash

set -euo pipefail

PACKAGES_INPUT_FILE="$1"

if [[ -f "$PACKAGES_INPUT_FILE" ]]; then
  echo "Processing $PACKAGES_INPUT_FILE to extract medadata..."

  if [[ -f packages_list.txt ]]; then
    rm -rf packages_list.txt
  fi
  
fi

grep -Eo '<package id="[^"]+" version="[^"]+"' "$PACKAGES_INPUT_FILE" | sed -E 's/<package id="([^"]+)" version="([^"]+)"/\1\t\2/' > packages_list.txt

#while IFS=$'\t' read -r package version; do
#    sed -i "/<group targetFramework=\".NETFramework4.8\">/a\ \ \ \     <dependency id=\"$package\" version=\"$version\" />" template.nuspec
#done < packages_list.txt

awk -v OFS="\n" '/<group targetFramework=".NETFramework4.8">/ {
    print $0;
    while ((getline < "packages_list.txt") > 0) {
        split($0, arr, "\t");
        print "        <dependency id=\"" arr[1] "\" version=\"" arr[2] "\" />";
    }
    next;
}1' template.nuspec > temp.nuspec && mv temp.nuspec template.nuspec
