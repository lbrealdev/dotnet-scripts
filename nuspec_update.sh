#!/bin/bash

#set -euo pipefail

#set -x

if [ "$#" -lt 1 ]; then
  echo "Usage: ./$(basename "$0") <directory>"
  exit 1
fi

INPUT_DIRECTORY="$1"
SCRIPT_DIR=$(dirname "$(realpath "$0")")
TEMPLATE_FILE="$SCRIPT_DIR/template.nuspec"

if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "Error: Template template.nuspec not found!"
  exit 1
fi

echo "Template found at: $TEMPLATE_FILE"
echo ""

function read_packages_config_file() {
  if [[ ! -f packages.config ]]; then
    echo "Warning: packages.config not found. Continuing without dependencies."
    return
  fi

  if [[ ! -s packages.config ]]; then
    echo "Warning: packages.config is empty. No dependencies to process."
    return
  fi

  grep -Eo '<package id="[^"]+" version="[^"]+"' packages.config | sed -E 's/<package id="([^"]+)" version="([^"]+)"/\1\t\2/' > packages_list.txt

  # if [[ ! -s packages_list.txt ]]; then
  #   echo "Warning: No dependencies found in packages.config. Skipping update."
  #   rm -f packages_list.txt
  #   exit 0
  # fi
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

function replace_template_tokens() {
  local id="$1"
  local version="$2"

  id=$(echo "$id" | sed 's/[&/\]/\\&/g')
  version=$(echo "$version" | sed 's/[&/\]/\\&/g')

  awk -v id="$id" -v version="$version" '
    { 
      gsub("\\$id\\$", id);
      gsub("\\$version\\$", version);
      print;
    }
  ' template.nuspec > temp.nuspec && mv temp.nuspec template.nuspec
}

if [[ -d "$INPUT_DIRECTORY" ]]; then
  echo "Fetching packages.config in the $INPUT_DIRECTORY directory..."
  cd "$INPUT_DIRECTORY" || exit 1


  rm -f packages_list.txt template.nuspec

  echo "Reading packages.config..."
  read_packages_config_file

  echo "Copying template.nuspec..."
  cp "$TEMPLATE_FILE" .
  
  echo "Updating nuspec dependencies..."
  update_template

  echo "Replacing template tokens..."
  replace_template_tokens "MyFirstTestProjectNet48" "1.0.0"

  echo "Done!"
  exit 0
else
  echo "Error: Directory $INPUT_DIRECTORY not found!"
  exit 1
fi
