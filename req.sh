#!/data/data/com.termux/files/usr/bin/bash

echo "[*] Storage permission setup kar rahe hain..."
termux-setup-storage

echo "[*] Packages update aur upgrade kar rahe hain..."
pkg update -y && pkg upgrade -y

echo "[*] Zaruri packages install kar rahe hain (Python, Git, Dos2unix)..."
pkg install python git dos2unix -y

echo "[*] Python PIP update aur packages install kar rahe hain..."
python -m pip install --upgrade pip
pip install requests beautifulsoup4

echo "[✔] Requirements complete! Ab aap 'bash main.sh' chala sakte hain."
