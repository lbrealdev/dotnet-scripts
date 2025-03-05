#!/bin/bash

set -euo pipefail

TEMPLATE="$1"

sed -i '/<dependencies>/,/<\/dependencies>/{
  /<dependency.*>/d
}' "$TEMPLATE"
