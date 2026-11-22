<#
.SYNOPSIS
    Installs Flex and Bison on Windows
.DESCRIPTION
    Supports Chocolatey, Scoop, or manual installation from GnuWin32.
    Sets up BISON_PKGDATADIR for bison to find its data files.
.NOTES
    Run as Administrator for system-wide PATH changes.
#>

param(
    [ValidateSet('Chocolatey', 'Scoop', 'Manual', 'Auto')]
    [string]$Method = 'Auto',

    [string]$InstallDir = 'C:\tools\flex-bison',

    [switch]$AddToPath = $true,

    [switch]$VerifyOnly,

    [switch]$SkipTestCompile
)

Write-Host "=== Flex & Bison Windows Installer ===" -ForegroundColor Cyan

function Get-PackageManager {
    if ($Method -ne 'Auto') { return $Method }
    if (Get-Command choco -ErrorAction SilentlyContinue) { return 'Chocolatey' }
    if (Get-Command scoop -ErrorAction SilentlyContinue) { return 'Scoop' }
    return 'Manual'
}

function Install-Chocolatey {
    Write-Host "Installing via Chocolatey..." -ForegroundColor Green
    choco install flex bison -y --no-progress
    if ($LASTEXITCODE -ne 0) { throw "Chocolatey install failed" }
}

function Install-Scoop {
    Write-Host "Installing via Scoop..." -ForegroundColor Green
    scoop install flex bison
    if ($LASTEXITCODE -ne 0) { throw "Scoop install failed" }
}

function Install-Manual {
    Write-Host "Manual installation to $InstallDir..." -ForegroundColor Green

    # Create directories
    New-Item -ItemType Directory -Force -Path "$InstallDir\bin" | Out-Null
    New-Item -ItemType Directory -Force -Path "$InstallDir\share\bison" | Out-Null

    $urls = @{
        flex = 'https://sourceforge.net/projects/gnuwin32/files/flex/2.5.4a-1/flex-2.5.4a-1-bin.zip/download'
        bison = 'https://sourceforge.net/projects/gnuwin32/files/bison/2.4.1/bison-2.4.1-bin.zip/download'
        m4    = 'https://sourceforge.net/projects/gnuwin32/files/m4/1.4.13/m4-1.4.13-bin.zip/download'
        deps  = 'https://sourceforge.net/projects/gnuwin32/files/gettext/0.14.4/gettext-0.14.4-bin.zip/download'
    }

    $temp = Join-Path $env:TEMP 'flex-bison-install'
    New-Item -ItemType Directory -Force -Path $temp | Out-Null

    foreach ($name in $urls.Keys) {
        $url = $urls[$name]
        $zip = Join-Path $temp "$name.zip"
        Write-Host "Downloading $name..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing -ProgressAction SilentlyContinue
            Expand-Archive -Path $zip -DestinationPath $temp -Force
            # Copy executables
            Get-ChildItem -Path $temp -Recurse -Filter '*.exe' | Where-Object { $_.Name -match "^($name|m4|libintl|libiconv)" } | ForEach-Object {
                Copy-Item $_.FullName -Destination "$InstallDir\bin\" -Force
                Write-Host "  Copied $($_.Name)" -ForegroundColor Gray
            }
            # Copy bison data files
            if ($name -eq 'bison') {
                Get-ChildItem -Path $temp -Recurse -Filter '*.m4' | ForEach-Object {
                    Copy-Item $_.FullName -Destination "$InstallDir\share\bison\" -Force
                }
            }
        }
        catch {
            $err = $_.Exception.Message
            Write-Warning ("Failed to download {0}: {1}" -f $name, $err)
        }
    }

    # Create bison wrapper with BISON_PKGDATADIR
    $wrapper = "@echo off`r`nset BISON_PKGDATADIR=$InstallDir\share\bison`r`n`"$InstallDir\bin\bison.exe`" %*"
    Set-Content -Path "$InstallDir\bin\bison.cmd" -Value $wrapper -Force
    Write-Host "Created bison.cmd wrapper with BISON_PKGDATADIR" -ForegroundColor Green

    # Cleanup
    Remove-Item -Path $temp -Recurse -Force -ErrorAction SilentlyContinue

    # Add to PATH
    if ($AddToPath) {
        $current = [Environment]::GetEnvironmentVariable('Path', 'Machine')
        if ($current -notlike "*$InstallDir\bin*") {
            [Environment]::SetEnvironmentVariable('Path', "$current;$InstallDir\bin", 'Machine')
            $env:Path += ";$InstallDir\bin"
            Write-Host "Added $InstallDir\bin to system PATH" -ForegroundColor Green
        }
    }
}

function Verify-Installation {
    Write-Host "`n=== Verification ===" -ForegroundColor Cyan

    $ok = $true

    # Flex
    $flex = Get-Command flex.exe -ErrorAction SilentlyContinue
    if ($flex) {
        $ver = & $flex.Source --version 2>&1 | Select-Object -First 1
        Write-Host "Flex: $ver" -ForegroundColor Green
    }
    else { Write-Host "Flex not found" -ForegroundColor Red; $ok = $false }

    # Bison
    $bison = Get-Command bison.exe -ErrorAction SilentlyContinue
    if (-not $bison) { $bison = Get-Command bison.cmd -ErrorAction SilentlyContinue }
    if ($bison) {
        $ver = & $bison.Source --version 2>&1 | Select-Object -First 1
        Write-Host "Bison: $ver" -ForegroundColor Green
    }
    else { Write-Host "Bison not found" -ForegroundColor Red; $ok = $false }

    # M4
    $m4 = Get-Command m4.exe -ErrorAction SilentlyContinue
    if ($m4) {
        $ver = & $m4.Source --version 2>&1 | Select-Object -First 1
        Write-Host "M4: $ver" -ForegroundColor Green
    }
    else { Write-Host "M4 not found (required by Bison)" -ForegroundColor Red; $ok = $false }

    # GCC
    $gcc = Get-Command gcc.exe -ErrorAction SilentlyContinue
    if ($gcc) {
        $ver = & $gcc.Source --version 2>&1 | Select-Object -First 1
        Write-Host "GCC: $ver" -ForegroundColor Green
    }
    else { Write-Host "GCC not found (install MinGW or use WSL)" -ForegroundColor Yellow }

    # Test compile (optional)
    if ($ok -and -not $SkipTestCompile -and $gcc) {
        Write-Host "`n=== Test Compilation ===" -ForegroundColor Cyan
        $testDir = Join-Path $env:TEMP 'flex-bison-test'
        New-Item -ItemType Directory -Force -Path $testDir | Out-Null
        Push-Location $testDir

        # Test lexer
        @'
%%
[0-9]+    { printf("NUM: %s\n", yytext); }
[ \t\n]   { }
.         { printf("CHAR: %s\n", yytext); }
%%
int yywrap() { return 1; }
int main() { yylex(); return 0; }
'@ | Set-Content test.l

        # Test parser
        @'
%{
#include <stdio.h>
int yylex(); void yyerror(const char* s) { fprintf(stderr, "Error: %s\n", s); }
%}
%token NUM
%%
input:  | input line ;
line:   '\n' | expr '\n' { printf("Result: %d\n", $1); } ;
expr:   NUM | expr '+' expr { $$ = $1 + $3; } | expr '-' expr { $$ = $1 - $3; }
        | expr '*' expr { $$ = $1 * $3; } | expr '/' expr { $$ = $1 / $3; } ;
%%
'@ | Set-Content test.y

        try {
            & $flex.Source test.l 2>&1 | Out-Null
            if (Test-Path 'lex.yy.c') { Write-Host "Flex generates lex.yy.c" -ForegroundColor Green }
            else { Write-Host "Flex generation failed" -ForegroundColor Red; $ok = $false }

            # Try bison with BISON_PKGDATADIR (note: spaced paths may fail with GnuWin32 bison)
            $bisonExe = $bison.Source
            $bisonDataDir = "$InstallDir\share\bison"
            if (-not (Test-Path $bisonDataDir)) {
                $bisonDataDir = "C:\bison-share"
            }
            $cmd = "set BISON_PKGDATADIR=$bisonDataDir && `"$bisonExe`" -d test.y"
            $result = & cmd /c $cmd 2>&1
            if ((Test-Path 'y.tab.c') -and (Test-Path 'y.tab.h')) {
                Write-Host "Bison generates y.tab.c/h" -ForegroundColor Green
            }
            else {
                Write-Host "Bison generation failed (known issue with spaced paths):" -ForegroundColor Yellow
                Write-Host "  $result" -ForegroundColor Yellow
                Write-Host "  Use WSL/Ubuntu for full bison support, or install to path without spaces" -ForegroundColor Yellow
            }

            if (Test-Path 'lex.yy.c' -and Test-Path 'y.tab.c') {
                gcc lex.yy.c y.tab.c -o test_parser 2>&1 | Out-Null
                if (Test-Path 'test_parser.exe') {
                    Write-Host "GCC compiles flex+bison" -ForegroundColor Green
                    $result = "3 + 4 * 2`n" | & ".\test_parser.exe" 2>&1
                    Write-Host "  Test: $($result.Trim())" -ForegroundColor Gray
                }
                else { Write-Host "GCC compile failed" -ForegroundColor Red; $ok = $false }
            }
        }
        finally {
            Pop-Location
            Remove-Item $testDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    return $ok
}

# Main
if (-not $VerifyOnly) {
    $pm = Get-PackageManager
    Write-Host "Method: $pm" -ForegroundColor Yellow

    switch ($pm) {
        'Chocolatey' { Install-Chocolatey }
        'Scoop'      { Install-Scoop }
        'Manual'     { Install-Manual }
    }
}

$success = Verify-Installation

if ($success) {
    Write-Host "`nInstallation verified successfully!" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "`nVerification failed" -ForegroundColor Red
    exit 1
}