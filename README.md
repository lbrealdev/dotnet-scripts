# dotnet-scripts

### Usage

Extracting values from packages.config:
```
grep -Eo '<package id="[^"]+" version="[^"]+"' packages.config | sed -E 's/<package id="([^"]+)" version="([^"]+)"/\1\t\2/'
```

