#!/usr/bin/env bash
# ================================================================
#  AWS EXPLORER — CLEANUP
#  Nothing to delete — no resources were created.
# ================================================================
Y='\033[1;33m'; NC='\033[0m'
banner()  { echo -e "\n${Y}══════════════════════════════════════════${NC}"; \
            echo -e "${Y}  $*${NC}"; \
            echo -e "${Y}══════════════════════════════════════════${NC}\n"; }

banner "AWS EXPLORER — CLEANUP"
echo -e "  Explorer Lab creates no AWS resources — nothing to delete.\n"
