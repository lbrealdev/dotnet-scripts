#!/bin/bash

set -euo pipefail

FILE="$1"

sed -i '/<dependencies>/,/<\/dependencies>/{
  /<dependency.*>/d
}' "$FILE"
