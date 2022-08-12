[![Maintenance](https://img.shields.io/maintenance/yes/2022.svg?style=flat-square)]()
# Microsoft Sentinel - Analytics Rules Validator

This GitHub action can be used to validate Microsoft Sentinel Analytics rules in both JSON and YML format.
>Add the following code block to your Github workflow:

```yaml
name: Analytics
on: push

jobs:
  pester-test:
    name: validate detections
    runs-on: windows-latest
    steps:
      - name: Check out repository code
        uses: actions/checkout@v3
      - name: Validate Sentinel Analytics Rules
        uses: f-bader/validate-detections@v2
        with:
          filesPath: templates
          logLevel: Minimal
```

### Inputs

This Action defines the following formal inputs.

| Name | Req | Description
|-|-|-|
| **`filesPath`**  | false | Path to the directory that contain the files to be tested, relative to the root of the project. This path is optional and defaults to the project root, in which case all files across the entire project tree will be discovered.
| **`logLevel`** | false | This indicates the verbosity of the testing engine. The default is set to `Normal` which shows all the passed and failed tests in the output. Optional values are `None, Minimal, Normal, Detailed, Diagnostic` When using `Minimal` only non-passed test results will be shown. The available verbosity options are based on the [pester](https://pester-docs.netlify.app/docs/commands/Invoke-Pester#-show) documentation. 

## Current incuded tests

TBD

## Current limitations / Under Development

- No support for Hunting Queries
- No support for Fusion rules
