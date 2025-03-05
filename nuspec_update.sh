#!/bin/bash

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: ./$(basename "$0") <directory>"
  exit 1
fi

INPUT_DIRECTORY="$1"

function read_packages_config_file() {
  grep -Eo '<package id="[^"]+" version="[^"]+"' packages.config | sed -E 's/<package id="([^"]+)" version="([^"]+)"/\1\t\2/' > packages_list.txt
}

function update_template() {
  awk -v OFS="\n" '/<group targetFramework=".NETFramework4.8">/ {
      print $0;
      while ((getline < "packages_list.txt") > 0) {
          split($0, arr, "\t");
          print "        <dependency id=\"" arr[1] "\" version=\"" arr[2] "\" />";
      }
      next;
  }1' template.nuspec > temp.nuspec && mv temp.nuspec template.nuspec
}

if [[ -d "$INPUT_DIRECTORY" ]]; then
  echo "Fetching packages.config in the $INPUT_DIRECTORY directory..."

  cd "$INPUT_DIRECTORY" || exit

  if [[ ! -f packages.config ]]; then
    echo "The packages.config file was not found!"
  fi

  if [[ -f packages_list.txt ]] || [[ -f template.nuspec ]]; then
    echo "Deleting old files..."
    rm -rf packages_list.txt template.nuspec
  fi

  echo "Reading packages.config..."
  read_packages_config_file

  echo "Adding dependencies in nuspec template..."
  cp ../template.nuspec .
  update_template

  echo "Done!"
  exit 0
else
  echo "The $INPUT_DIRECTORY directory was not found!"
fi
