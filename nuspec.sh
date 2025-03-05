#!/bin/bash

set -eou pipefail

CSPROJ_FILE="$1"
INPUT_NUSPEC_FILE="$2"
OUTPUT_NUSPEC_FILE="${INPUT_NUSPEC_FILE%.nuspec}-formatted.nuspec"


echo "Reading and extracting dependencies from $CSPROJ_FILE..."

grep -Eo '<PackageReference Include="[^"]+" Version="[^"]+"' "$CSPROJ_FILE" | \
sed -E 's/<PackageReference Include="([^"]+)" Version="([^"]+)"/\1\t\2/' | \
awk -F '\t' '{ print "    <dependency id=\"" $1 "\" version=\"" $2 "\" />" }' > dependencies.xml

echo "Reading and extracting assemblies from $CSPROJ_FILE..."

grep -Eo '<Reference Include="System[^"]*"' "$CSPROJ_FILE" | \
sed -E 's/<Reference Include="([^"]+)"/\1/' | \
awk '{ print "    <frameworkAssembly assemblyName=\"" $1 "\" />" }' > assemblies.xml

echo "Generating a new nuspec file with these values..."

awk '
  BEGIN { insideDependencies=0; insideFramework=0 }

  /<dependencies>/ { 
    insideDependencies=1; 
    print "    <dependencies>\n      <group targetFramework=\".NETFramework4.8\">"; 
    next 
  }
  /<\/dependencies>/ { 
    insideDependencies=0; 
    while ((getline line < "dependencies.xml") > 0) print "    " line;
    close("dependencies.xml");
    print "      </group>\n    </dependencies>"; 
    next 
  }

  /<frameworkAssemblies>/ { 
    insideFramework=1; 
    print "    <frameworkAssemblies>"; 
    next 
  }
  /<\/frameworkAssemblies>/ { 
    insideFramework=0; 
    while ((getline line < "assemblies.xml") > 0) print "  " line;
    close("assemblies.xml");
    print "    </frameworkAssemblies>"; 
    next 
  }

  !insideDependencies && !insideFramework { print }
' "$INPUT_NUSPEC_FILE" > format.nuspec && mv format.nuspec "$OUTPUT_NUSPEC_FILE"

echo "Done!"