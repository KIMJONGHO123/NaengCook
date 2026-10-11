# Run from any directory in an interactive PowerShell terminal.
[CmdletBinding()]
param(
    [string]$MySqlPath = 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe',
    [string]$AdminUser = 'root',
    [System.Security.SecureString]$AdminPassword
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$envPath = Join-Path $projectRoot '.env'
if (!(Test-Path -LiteralPath $MySqlPath)) {
    throw 'mysql.exe not found. Supply -MySqlPath with your installation path.'
}
if (!(Test-Path -LiteralPath $envPath)) {
    throw 'Copy .env.example to .env and set MYSQL_PASSWORD first.'
}
$settings = @{}
foreach ($line in Get-Content -LiteralPath $envPath) {
    if ($line -match '^([A-Z_]+)=(.*)$') { $settings[$Matches[1]] = $Matches[2].Trim() }
}
$database = $settings['MYSQL_DATABASE']
$appUser = $settings['MYSQL_USER']
$appPassword = $settings['MYSQL_PASSWORD']
$dbHost = $settings['DB_HOST']
$dbPort = $settings['MYSQL_PORT']
if ($database -notmatch '^[A-Za-z0-9_]+$' -or $appUser -notmatch '^[A-Za-z0-9_]+$') {
    throw 'Use only letters, digits and underscores for database and user names.'
}
if ($appUser -eq 'root') { throw 'Use a dedicated project account, not root.' }
if ($appPassword -notmatch '^[A-Za-z0-9_-]{12,}$' -or $appPassword -like 'replace_*') {
    throw 'Set MYSQL_PASSWORD to at least 12 letters/digits/underscores/hyphens in .env.'
}
if ($dbHost -notin @('localhost','127.0.0.1') -or $dbPort -notmatch '^\d{1,5}$') {
    throw 'This setup script only supports a local MySQL server with a numeric port.'
}
$sql = @"
CREATE DATABASE IF NOT EXISTS ``$database`` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE USER IF NOT EXISTS '$appUser'@'localhost' IDENTIFIED BY '$appPassword';
GRANT ALL PRIVILEGES ON ``$database``.* TO '$appUser'@'localhost';
SELECT VERSION() AS mysql_version;
"@
Write-Host 'This creates the project database and grants access to a dedicated localhost account.'
Write-Host 'Existing account passwords are not changed.'
if ($AdminUser -notmatch '^[A-Za-z0-9_]+$') { throw 'Invalid administrator account name.' }
if (!$AdminPassword) { $AdminPassword = Read-Host 'MySQL administrator password (do not enter in chat)' -AsSecureString }
$passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($AdminPassword)
$mysqlProcess = New-Object System.Diagnostics.Process
try {
    $mysqlProcess.StartInfo.FileName = $MySqlPath
    $mysqlProcess.StartInfo.Arguments = "--protocol=TCP --host=$dbHost --port=$dbPort --user=$AdminUser --batch"
    $mysqlProcess.StartInfo.UseShellExecute = $false
    $mysqlProcess.StartInfo.RedirectStandardInput = $true
    # Secret exists only in this child process environment, never in argv or a file.
    $mysqlProcess.StartInfo.EnvironmentVariables['MYSQL_PWD'] = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)
    [void]$mysqlProcess.Start()
    $mysqlProcess.StartInfo.EnvironmentVariables.Remove('MYSQL_PWD')
    $mysqlProcess.StandardInput.WriteLine($sql)
    $mysqlProcess.StandardInput.Close()
    $mysqlProcess.WaitForExit()
    if ($mysqlProcess.ExitCode -ne 0) { throw 'MySQL setup failed. Check the administrator login and permissions.' }
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
    $mysqlProcess.Dispose()
}
Write-Host 'Database setup completed. Start the backend from apps/server with .\gradlew.bat bootRun.'
Write-Host 'If the project account already existed, ensure .env contains its existing password.'
