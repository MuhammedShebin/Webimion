#!/bin/bash
# ANSI colors for styling
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Fancy Banner
echo -e "${CYAN}"
echo "      __        __   _     _           _             "
echo "      \ \      / /__| |__ (_)_ __ ___ (_) ___  _ __  "
echo "       \ \ /\ / / _ \ '_ \| | '_ \` _ \| |/ _ \| '_ \ "
echo "        \ V  V /  __/ |_) | | | | | | | | (_) | | | |"
echo "         \_/\_/ \___|_.__/|_|_| |_| |_|_|\___/|_| |_|"
echo -e "${GREEN}            Automated Black-Box Web Recon Tool"
echo -e "${RED}                  by Muhammed Shebin M (MSPen)"
echo -e "${NC}"

TARGET=$1
WORKDIR="$TARGET/recon"
GREEN="\e[32m"; RED="\e[31m"; YELLOW="\e[33m"; NC="\e[0m"

if [ -z "$TARGET" ]; then
  echo -e "${RED}Usage: $0 target.com${NC}"
  exit 1
fi

mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit

# Tool check and install
install_tool() {
  local name="$1" check="$2" install="$3"
  if ! command -v "$check" &>/dev/null; then
    echo -e "${YELLOW}[+] Installing $name...${NC}"
    eval "$install"
  else
    echo -e "${GREEN}[+] $name already installed.${NC}"
  fi
}

# Install essential tools
install_tool "subfinder" "subfinder" "apt install -y subfinder"
install_tool "httpx" "httpx" "go install github.com/projectdiscovery/httpx/cmd/httpx@latest"
install_tool "nuclei" "nuclei" "go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
install_tool "gau" "gau" "go install github.com/lc/gau/v2/cmd/gau@latest"
install_tool "waybackurls" "waybackurls" "go install github.com/tomnomnom/waybackurls@latest"
install_tool "gf" "gf" "go install github.com/tomnomnom/gf@latest && mkdir -p ~/.gf && git clone https://github.com/1ndianl33t/Gf-Patterns ~/.gf"
install_tool "dalfox" "dalfox" "go install github.com/hahwul/dalfox/v2@latest"
install_tool "katana" "katana" "go install github.com/projectdiscovery/katana/cmd/katana@latest"

# GitHub Dorker
if [ ! -d "GitDorker" ]; then
  git clone https://github.com/obheda12/GitDorker.git && cd GitDorker && pip3 install -r requirements.txt && cd ..
fi

echo -e "${GREEN}[+] Starting full recon for $TARGET${NC}"

# Subdomain enumeration
subfinder -d "$TARGET" -silent -o subs.txt

# Alive detection
httpx -l subs.txt -silent -o alive.txt

# Nuclei scanning
nuclei -l alive.txt -o nuclei.txt

# URL enumeration
gau "$TARGET" >> gau.txt
waybackurls "$TARGET" >> waybackurls.txt
katana -list alive.txt -o katana.txt

cat gau.txt waybackurls.txt katana.txt | sort -u > all_urls.txt

# GF pattern match
gf xss all_urls.txt >> gf_xss.txt
gf sqli all_urls.txt >> gf_sqli.txt

# XSS check
dalfox file gf_xss.txt -o dalfox_xss.txt

# GitHub Dorking
cd GitDorker
if [ ! -f "dorks.txt" ]; then
  curl -sO https://raw.githubusercontent.com/obheda12/GitDorker/main/dorks.txt
fi
python3 GitDorker.py -tf ../subs.txt -e dorks.txt -o ../github_dorks.txt
cd ..

# Google Dorking (Basic - manual enhancement possible)
echo -e "${YELLOW}[+] Top Google Dorks (Manual Input Required):${NC}" > google_dorks.txt
echo -e "site:$TARGET ext:env | ext:php | ext:txt" >> google_dorks.txt
echo -e "site:$TARGET inurl:login | inurl:admin | intitle:index.of" >> google_dorks.txt
echo -e "site:$TARGET filetype:log | filetype:sql" >> google_dorks.txt
echo -e "site:$TARGET intext:'DB_PASSWORD'" >> google_dorks.txt

echo -e "${GREEN}[+] Recon complete. Results in $WORKDIR${NC}"