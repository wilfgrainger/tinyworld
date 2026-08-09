[CmdletBinding()]
param(
    [switch]$CheckOnly,
    [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'

if ($args.Count -gt 0) {
    throw "Unknown argument(s): $($args -join ' ')"
}

function Require-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command missing: $Name"
    }
}

$rootDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$releaseConfigPath = Join-Path $rootDir 'config/release.json'

Require-Command 'git'
Require-Command 'rojo'
Require-Command 'Get-FileHash'

$release = Get-Content -Raw $releaseConfigPath | ConvertFrom-Json
$rojoVersionLines = & rojo --version
if ($LASTEXITCODE -ne 0) {
    throw "rojo --version failed with exit code $LASTEXITCODE; verify the installed Rojo executable"
}
$rojoVersionOutput = ($rojoVersionLines | Out-String).Trim()
$expectedOfficialRojoOutput = "Rojo $($release.rojoVersion)"
$expectedLowercaseRojoOutput = "rojo $($release.rojoVersion)"
if ($rojoVersionOutput -cne $expectedOfficialRojoOutput -and $rojoVersionOutput -cne $expectedLowercaseRojoOutput -and $rojoVersionOutput -cne [string]$release.rojoVersion) {
    throw "Rojo version must report exactly `"$expectedOfficialRojoOutput`", `"$expectedLowercaseRojoOutput`", or `"$($release.rojoVersion)`"; got: $rojoVersionOutput"
}

if ($CheckOnly) {
    Write-Output 'PASS: build prerequisites are available'
    exit 0
}

if (-not $OutputDirectory) {
    $OutputDirectory = if ($env:TINYWORLD_BUILD_DIR) {
        $env:TINYWORLD_BUILD_DIR
    } else {
        Join-Path $rootDir 'dist'
    }
}

$dirtyStatusLines = & git -C $rootDir status --porcelain
if ($LASTEXITCODE -ne 0) {
    throw "git status --porcelain failed with exit code $LASTEXITCODE; cannot verify that the working tree is clean"
}
$dirtyStatus = ($dirtyStatusLines | Out-String).Trim()
if ($env:TINYWORLD_ALLOW_DIRTY_BUILD -ne '1' -and $dirtyStatus) {
    throw 'Working tree is dirty; set TINYWORLD_ALLOW_DIRTY_BUILD=1 to override'
}

$commitLines = & git -C $rootDir rev-parse HEAD
if ($LASTEXITCODE -ne 0) {
    throw "git rev-parse HEAD failed with exit code $LASTEXITCODE; cannot record release commit metadata"
}
$commit = ($commitLines | Out-String).Trim()
if ($commit -notmatch '^[0-9a-f]{40}$') {
    throw "git rev-parse HEAD must return a full 40-character SHA; got: $commit"
}

$branchLines = & git -C $rootDir branch --show-current
if ($LASTEXITCODE -ne 0) {
    throw "git branch --show-current failed with exit code $LASTEXITCODE; cannot record release branch metadata"
}
$branch = ($branchLines | Out-String).Trim()
if (-not $branch) {
    $branch = if ($env:GITHUB_HEAD_REF) {
        $env:GITHUB_HEAD_REF
    } elseif ($env:GITHUB_REF_NAME) {
        $env:GITHUB_REF_NAME
    } else {
        'detached'
    }
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$artifactPath = Join-Path $OutputDirectory $release.artifactFile
$manifestPath = Join-Path $OutputDirectory 'release.json'
$projectPath = Join-Path $rootDir $release.projectFile

& rojo build $projectPath --output $artifactPath
if ($LASTEXITCODE -ne 0) {
    throw "rojo build failed with exit code $LASTEXITCODE for $projectPath; verify the project file and installed Rojo"
}

$sha256 = (Get-FileHash -Algorithm SHA256 $artifactPath).Hash.ToLowerInvariant()
$manifest = [ordered]@{
    productVersion = $release.productVersion
    releaseName = $release.releaseName
    commit = $commit
    branch = $branch
    buildTimestampUtc = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
    rojoVersion = $release.rojoVersion
    projectFile = $release.projectFile
    profileSchema = $release.profileSchema
    artifact = $release.artifactFile
    sha256 = $sha256
}
$json = $manifest | ConvertTo-Json
[System.IO.File]::WriteAllText($manifestPath, "$json$([Environment]::NewLine)", [System.Text.UTF8Encoding]::new($false))

Write-Output "Artifact: $artifactPath"
Write-Output "SHA-256: $sha256"
