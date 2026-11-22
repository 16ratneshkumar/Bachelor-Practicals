#!/bin/bash
# ============================================================
# Flex & Bison Installer for Ubuntu/Linux
# ============================================================
# Usage: sudo ./install-flex-bison-ubuntu.sh [options]
# Options:
#   --verify-only    Only verify existing installation
#   --help           Show this help
# ============================================================

set -euo pipefail

VERIFY_ONLY=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --verify-only) VERIFY_ONLY=true ;;
        --help)
            grep '^#' "$0" | cut -c4-
            exit 0
            ;;
        *) echo "Unknown option: $arg"; exit 1 ;;
    esac
done

echo "=== Flex & Bison Ubuntu Installer ==="

# Detect package manager
if command -v apt-get &>/dev/null; then
    PKG_MGR="apt"
elif command -v dnf &>/dev/null; then
    PKG_MGR="dnf"
elif command -v yum &>/dev/null; then
    PKG_MGR="yum"
elif command -v pacman &>/dev/null; then
    PKG_MGR="pacman"
elif command -v zypper &>/dev/null; then
    PKG_MGR="zypper"
else
    echo "Unsupported package manager"
    exit 1
fi

echo "Package manager: $PKG_MGR"

install_packages() {
    echo "Updating package list..."
    case $PKG_MGR in
        apt)    sudo apt-get update -y ;;
        dnf)    sudo dnf check-update || true ;;
        yum)    sudo yum check-update || true ;;
        pacman) sudo pacman -Sy ;;
        zypper) sudo zypper refresh ;;
    esac

    echo "Installing flex, bison, m4, build-essential..."
    case $PKG_MGR in
        apt)    sudo apt-get install -y flex bison m4 build-essential ;;
        dnf)    sudo dnf install -y flex bison m4 gcc gcc-c++ make ;;
        yum)    sudo yum install -y flex bison m4 gcc gcc-c++ make ;;
        pacman) sudo pacman -S --noconfirm flex bison m4 base-devel ;;
        zypper) sudo zypper install -y flex bison m4 gcc gcc-c++ make ;;
    esac
}

verify_installation() {
    echo ""
    echo "=== Verification ==="
    local ok=true

    # Flex
    if command -v flex &>/dev/null; then
        local ver=$(flex --version | head -1)
        echo -e "\033[32m✓ Flex: $ver\033[0m"
    else
        echo -e "\033[31m✗ Flex not found\033[0m"
        ok=false
    fi

    # Bison
    if command -v bison &>/dev/null; then
        local ver=$(bison --version | head -1)
        echo -e "\033[32m✓ Bison: $ver\033[0m"
    else
        echo -e "\033[31m✗ Bison not found\033[0m"
        ok=false
    fi

    # M4
    if command -v m4 &>/dev/null; then
        local ver=$(m4 --version | head -1)
        echo -e "\033[32m✓ M4: $ver\033[0m"
    else
        echo -e "\033[31m✗ M4 not found (required by Bison)\033[0m"
        ok=false
    fi

    # GCC
    if command -v gcc &>/dev/null; then
        local ver=$(gcc --version | head -1)
        echo -e "\033[32m✓ GCC: $ver\033[0m"
    else
        echo -e "\033[31m✗ GCC not found\033[0m"
        ok=false
    fi

    # Test compilation
    if $ok; then
        echo ""
        echo "=== Test Compilation ==="
        local test_dir=$(mktemp -d)
        cd "$test_dir"

        # Test lexer
        cat > test.l << 'EOF'
%%
[0-9]+    { printf("NUM: %s\n", yytext); }
[ \t\n]   { }
.         { printf("CHAR: %s\n", yytext); }
%%
int yywrap() { return 1; }
int main() { yylex(); return 0; }
EOF

        # Test parser
        cat > test.y << 'EOF'
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
EOF

        # Flex
        if flex test.l 2>/dev/null && [[ -f lex.yy.c ]]; then
            echo -e "\033[32m✓ Flex generates lex.yy.c\033[0m"
        else
            echo -e "\033[31m✗ Flex generation failed\033[0m"
            ok=false
        fi

        # Bison
        if bison -d test.y 2>/dev/null && [[ -f y.tab.c ]] && [[ -f y.tab.h ]]; then
            echo -e "\033[32m✓ Bison generates y.tab.c/h\033[0m"
        else
            echo -e "\033[31m✗ Bison generation failed\033[0m"
            ok=false
        fi

        # GCC
        if [[ -f lex.yy.c ]] && [[ -f y.tab.c ]]; then
            if gcc lex.yy.c y.tab.c -o test_parser 2>/dev/null && [[ -f test_parser ]]; then
                echo -e "\033[32m✓ GCC compiles flex+bison\033[0m"
                local result=$(echo "3 + 4 * 2" | ./test_parser 2>&1)
                echo -e "  Test: \033[90m$result\033[0m"
            else
                echo -e "\033[31m✗ GCC compile failed\033[0m"
                ok=false
            fi
        fi

        cd /
        rm -rf "$test_dir"
    fi

    return $($ok && echo 0 || echo 1)
}

# Main
if ! $VERIFY_ONLY; then
    install_packages
fi

if verify_installation; then
    echo ""
    echo -e "\033[32m✓ All tools installed and verified successfully!\033[0m"
    echo "Flex:  $(command -v flex)"
    echo "Bison: $(command -v bison)"
    echo "M4:    $(command -v m4)"
    echo "GCC:   $(command -v gcc)"
    exit 0
else
    echo ""
    echo -e "\033[31m✗ Verification failed\033[0m"
    exit 1
fi