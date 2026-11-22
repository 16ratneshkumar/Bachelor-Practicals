# Flex & Bison Installation Guide

Install Flex (lexical analyzer) and Bison (parser generator) for Compiler Design practicals.

---

## Windows

### Quick Start (PowerShell as Administrator)
```powershell
# Auto-detect best method (Chocolatey > Scoop > Manual)
.\install-flex-bison-windows.ps1

# Or force a specific method
.\install-flex-bison-windows.ps1 -Method Chocolatey
.\install-flex-bison-windows.ps1 -Method Scoop
.\install-flex-bison-windows.ps1 -Method Manual -InstallDir "C:\tools\flex-bison"

# Verify installation (skip test compile due to GnuWin32 path issue)
.\install-flex-bison-windows.ps1 -VerifyOnly -SkipTestCompile
```

### Requirements
- Windows 10/11
- PowerShell 5.1+
- Administrator rights (for PATH changes)

### Methods
| Method | Pros | Cons |
|--------|------|------|
| **Chocolatey** | Easy, auto-updates | Requires Chocolatey pre-installed |
| **Scoop** | User-space, no admin | Requires Scoop pre-installed |
| **Manual** | No dependencies | Manual updates |

### Known Issue
GnuWin32 Bison fails test compilation with spaced paths (`C:\Flex Windows\...`).
- **Workaround**: Use `-SkipTestCompile` flag
- **Full support**: Use WSL/Ubuntu or manual install to path without spaces

---

## Ubuntu / Linux

### Quick Start
```bash
chmod +x install-flex-bison-ubuntu.sh

# Install (requires sudo)
sudo ./install-flex-bison-ubuntu.sh

# Verify only
./install-flex-bison-ubuntu.sh --verify-only
```

### Supported Distributions
| Package Manager | Distributions |
|----------------|---------------|
| `apt` | Ubuntu, Debian, Linux Mint, Pop!_OS |
| `dnf` | Fedora, RHEL 8+, AlmaLinux, Rocky |
| `yum` | RHEL 7, CentOS 7 |
| `pacman` | Arch, Manjaro, EndeavourOS |
| `zypper` | openSUSE |

---

## What Gets Installed

| Tool | Version (typical) | Purpose |
|------|-------------------|---------|
| **flex** | 2.6.x | Generates `lex.yy.c` from `.l` files |
| **bison** | 3.x | Generates `y.tab.c` / `y.tab.h` from `.y` files |
| **m4** | 1.4.x | Macro processor (required by bison) |
| **gcc** | 9+ | C compiler for building generated code |

---

## Verification Output (Expected)

### Windows
```
Flex: C:\...\flex.exe version 2.5.4
Bison: bison (GNU Bison) 2.4.1
M4: m4 (GNU M4) 1.4.13
GCC: gcc.exe (MinGW.org GCC-6.3.0-1) 6.3.0

Installation verified successfully!
```

### Ubuntu
```
Flex: flex 2.6.4
Bison: bison (GNU Bison) 3.8.2
M4: m4 (GNU M4) 1.4.18
GCC: gcc (Ubuntu 11.4.0) 11.4.0

✓ Flex generates lex.yy.c
✓ Bison generates y.tab.c/h
✓ GCC compiles flex+bison
  Test: Result: 11

All tools installed and verified successfully!
```

---

## Usage in Compiler Design Practicals

After installation, build practicals with:
```bash
# Windows (via Makefile)
make p1          # Lex only
make p9          # Lex + Yacc

# Or manually
flex practical1.l && gcc lex.yy.c -o practical1.exe
bison -d practical9.y && flex practical9.l && gcc lex.yy.c y.tab.c -o practical9.exe
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `bison: command not found` | Restart terminal / run `refreshenv` (Chocolatey) |
| `m4 cannot open` (Windows) | Use manual install to path without spaces, or use WSL |
| `gcc not found` (Windows) | Install MinGW-w64 or use WSL |
| Permission denied (Ubuntu) | Run with `sudo` |
| Package not found (Ubuntu) | Run `sudo apt update` first |
