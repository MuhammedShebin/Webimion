# Webimion Recon – Automated Web Reconnaissance Toolkit 🕵️‍♂️

MSPen Recon is a black-box web application reconnaissance automation script designed for penetration testers and bug bounty hunters. It sets up a structured recon environment with necessary tool checks, installations, Google Dorking, and parallelized scanning inside a customized `tmux` workflow.

---

## 🔍 Features

- ✅ Auto-checks & installs required recon tools
- 🔄 Google Dorking-based passive recon
- 🧵 Custom `tmux` session with separate panes for tools
- 🚀 Runs active recon tools in parallel
- ✍️ Creates structured output directories for every target
- 🧩 Easily extensible with custom recon modules

---

## ⚙️ Tools Integrated

- `assetfinder`, `amass` – subdomain enumeration  
- `httpx`, `httprobe` – alive host detection  
- `waybackurls`, `gau` – URL collection  
- `nuclei` – vulnerability templates scanning  
- `gf` – pattern matching  
- `tmux` – session management  
- `curl`, `dig`, `whois` – passive intel gathering

---

## 🛠️ Installation

```bash
git clone https://github.com/yourhandle/mspen-recon
cd mspen-recon
chmod +x recon.sh
./recon.sh example.com
