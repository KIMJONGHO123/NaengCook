# Download the pinned Windows x64 Node runtime without changing system PATH.
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$nodeVersion = (Get-Content (Join-Path $projectRoot '.nvmrc') -Raw).Trim()
if ($nodeVersion -notmatch '^\d+\.\d+\.\d+$') { throw 'Invalid version in .nvmrc' }
if (![Environment]::Is64BitOperatingSystem) { throw 'Windows x64 is required by this setup script.' }
$toolsPath = Join-Path $projectRoot '.tools'
New-Item -ItemType Directory -Force -Path $toolsPath | Out-Null
$archiveName = "node-v$nodeVersion-win-x64.zip"
$archivePath = Join-Path $toolsPath $archiveName
$checksumsPath = Join-Path $toolsPath 'SHASUMS256.txt'
$releaseUrl = "https://nodejs.org/dist/v$nodeVersion"
Invoke-WebRequest "$releaseUrl/$archiveName" -OutFile $archivePath -UseBasicParsing
Invoke-WebRequest "$releaseUrl/SHASUMS256.txt" -OutFile $checksumsPath -UseBasicParsing
$checksumLine = Get-Content $checksumsPath | Where-Object { $_ -match ('\s+' + [regex]::Escape($archiveName) + '$') } | Select-Object -First 1
if (!$checksumLine) { throw 'Archive missing from official checksum list' }
$expectedHash = ($checksumLine.Trim() -split '\s+')[0]
if ((Get-FileHash $archivePath -Algorithm SHA256).Hash -ne $expectedHash) {
    throw 'Node download checksum mismatch'
}
Expand-Archive -LiteralPath $archivePath -DestinationPath $toolsPath -Force
& (Join-Path $toolsPath "node-v$nodeVersion-win-x64/node.exe") --version
if ($LASTEXITCODE -ne 0) { throw 'Downloaded Node could not run' }
Write-Host 'Project Node is ready. Run mobile.cmd from the project root.'
