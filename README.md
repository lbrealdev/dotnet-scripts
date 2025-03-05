# dotnet-scripts

### Usage

Extracting values from packages.config:
```
grep -Eo '<package id="[^"]+" version="[^"]+"' packages.config | sed -E 's/<package id="([^"]+)" version="([^"]+)"/\1\t\2/'
```

Extracting values from project.csproj:
```
grep -Eo '<Reference Include="[^"]+"' CheckinRESTService.csproj | sed -E 's/<Reference Include="([^"]+)" Version="([^"]+)"/\1\t\2/'
```


