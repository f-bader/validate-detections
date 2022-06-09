param (
    [parameter(Mandatory = $false)]
    [string]$FilesPath,
    
    [parameter(Mandatory = $false)]
    [string]$logLevel
)

## Install NuGet for KQL parsing
## https://stackoverflow.com/questions/70166382/validate-kusto-query-before-submitting-it
if (-not (Get-PackageProvider -Name 'NuGet')) {
    Write-Output "Install PackageProvider NuGet"
    Install-PackageProvider -Name NuGet -Scope CurrentUser -Force
    Write-Output "Register PackageSource nuget.org"
    Register-PackageSource -Name nuget.org -ProviderName NuGet  -Location https://www.nuget.org/api/v2 -Force
}

## Make sure any packages we depend on are installed
$packageToInstall = @(
    'Microsoft.Azure.Kusto.Language'
)

$packageToInstall | ForEach-Object {
    if (-not (Get-Package $_ -EA 0)) {
        Write-Output "Install-Package [$_]"
        Install-Package -Name $_ -ProviderName NuGet -Scope CurrentUser -Force
    }
}

## Make sure any modules we depend on are installed
$modulesToInstall = @(
    'Pester'
    'powershell-yaml'
)

$modulesToInstall | ForEach-Object {
    if (-not (Get-Module -ListAvailable -All $_)) {
        Write-Output "Module [$_] not found, INSTALLING..."
        Install-Module $_ -Force
    }
}

$modulesToInstall | ForEach-Object {
    Write-Output "Importing Module [$_]"
    Import-Module $_ -Force
}

# Import Mitre Att&ck mapping
Write-Output 'Loading Mitre Att&ck framework'
$global:attack = (Get-ChildItem -Path "$($PSScriptRoot)\mitre.csv" -Recurse | Get-Content | ConvertFrom-CSV)

# Load Kusto Language support library
$nuGetPath = Get-Package -Name "Microsoft.Azure.Kusto.Language" | Select-Object -ExpandProperty Source
$dllPath = (Split-Path -Path $nuGetPath) + "\lib\netstandard2.0\Kusto.Language.dll"
[System.Reflection.Assembly]::LoadFrom($dllPath) | Out-Null

if ($FilesPath -ne '.') {
    Write-Output  "Selected filespath is [$FilesPath]"
    Get-ChildItem "*.tests.ps1" | Copy-Item -Destination $FilesPath -Force
    $global:detectionsPath = $FilesPath
}

$PesterConfig = [PesterConfiguration]@{
    Run         = @{
        Path = "$($PSScriptRoot)"
    }
    Output      = @{
        Verbosity = "$logLevel"
    }
    TestResults = @{
        OutputFormat = 'NuUnitXml'
        OutputPath   = "."
    }
    Should      = @{
        ErrorAction = 'Continue'
    }
}

Invoke-Pester -Configuration $PesterConfig
