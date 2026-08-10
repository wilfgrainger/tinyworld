[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$rootDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$temporaryDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("tinyworld-build-contract-" + [guid]::NewGuid().ToString('N'))
$originalPath = $env:PATH
$originalDirtyOverride = $env:TINYWORLD_ALLOW_DIRTY_BUILD
$originalVersionOutput = $env:TINYWORLD_TEST_ROJO_VERSION

function Restore-Environment {
    $env:PATH = $originalPath
    $env:TINYWORLD_ALLOW_DIRTY_BUILD = $originalDirtyOverride
    $env:TINYWORLD_TEST_ROJO_VERSION = $originalVersionOutput
    if (Test-Path $temporaryDirectory) {
        Remove-Item -Recurse -Force $temporaryDirectory
    }
}

function Assert-CheckRejects {
    param([string]$VersionOutput)

    $env:TINYWORLD_TEST_ROJO_VERSION = $VersionOutput
    try {
        & (Join-Path $rootDir 'scripts/build.ps1') -CheckOnly
    } catch {
        if ($_.Exception.Message -match 'Rojo version must report exactly') {
            return
        }
        throw
    }

    throw "Rojo version output should be rejected: $VersionOutput"
}

try {
    New-Item -ItemType Directory -Path $temporaryDirectory | Out-Null
    $rojoStub = Join-Path $temporaryDirectory 'rojo.cmd'
    [System.IO.File]::WriteAllText($rojoStub, @'
@echo off
if "%~1"=="--version" (
  echo %TINYWORLD_TEST_ROJO_VERSION%
  exit /b 0
)
if not "%~1"=="build" exit /b 1
set output=
:parse
if "%~1"=="" goto write
if "%~1"=="--output" (
  set output=%~2
  shift
)
shift
goto parse
:write
if "%output%"=="" exit /b 1
> "%output%" echo ^<roblox version="4"^>^<Item class="DataModel" referent="RBX0" /^>^</roblox^>
'@, [System.Text.UTF8Encoding]::new($false))

    $env:PATH = "$temporaryDirectory;$env:PATH"
    Assert-CheckRejects 'rojo 7.7.0-rc.1'
    Assert-CheckRejects 'rojo 7.7.0+modified'
    Assert-CheckRejects 'RoJo 7.7.0'

    $env:TINYWORLD_TEST_ROJO_VERSION = 'Rojo 7.7.0'
    & (Join-Path $rootDir 'scripts/build.ps1') -CheckOnly

    $env:TINYWORLD_TEST_ROJO_VERSION = 'rojo 7.7.0'
    & (Join-Path $rootDir 'scripts/build.ps1') -CheckOnly

    $outputDirectory = Join-Path $temporaryDirectory 'dist'
    $env:TINYWORLD_ALLOW_DIRTY_BUILD = '1'
    & (Join-Path $rootDir 'scripts/build.ps1') -OutputDirectory $outputDirectory

    $artifactPath = Join-Path $outputDirectory 'TinyWorld-v0.6.0.rbxlx'
    $manifestPath = Join-Path $outputDirectory 'release.json'
    if (-not (Test-Path $artifactPath) -or -not (Test-Path $manifestPath)) {
        throw 'PowerShell build did not produce the artifact and manifest'
    }

    $manifest = Get-Content -Raw $manifestPath | ConvertFrom-Json
    if ($manifest.productVersion -ne '0.6.0' -or $manifest.rojoVersion -ne '7.7.0' -or $manifest.artifact -ne 'TinyWorld-v0.6.0.rbxlx' -or $manifest.profileSchema -ne 11 -or $manifest.buildTimestampUtc -notmatch '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$') {
        throw 'PowerShell build manifest did not satisfy the v0.6.0 release contract'
    }

    if ($manifest.sha256 -ne (Get-FileHash -Algorithm SHA256 $artifactPath).Hash.ToLowerInvariant()) {
        throw 'PowerShell build manifest SHA-256 did not match the artifact'
    }
} finally {
    Restore-Environment
}
