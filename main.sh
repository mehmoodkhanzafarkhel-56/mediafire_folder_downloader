#!/data/data/com.termux/files/usr/bin/bash

echo "[*] Ultra-Fast MediaFire Downloader Script (~/mf_folder.py) bana rahe hain..."

cat << 'EOF' > ~/mf_folder.py
import requests
import json
import re
import sys
import os
from concurrent.futures import ThreadPoolExecutor

def get_all_folder_files(folder_key):
    files = []
    chunk = 1
    more_chunks = True
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}

    print("[*] MediaFire API se saari files ki list nikaal rahe hain...")
    while more_chunks:
        url = f"https://www.mediafire.com/api/1.4/folder/get_content.php?content_type=files&filter=all&order_by=name&order_direction=asc&chunk={chunk}&version=1.5&folder_key={folder_key}&response_format=json"
        
        try:
            r = requests.get(url, headers=headers)
            data = r.json()
            folder_content = data['response']['folder_content']
            
            file_list = folder_content.get('files', [])
            if not file_list:
                break
                
            for item in file_list:
                files.append(item['links']['normal_download'])
                
            more_chunks_flag = folder_content.get('more_chunks', 'no')
            if more_chunks_flag == 'yes':
                chunk += 1
            else:
                more_chunks = False
        except Exception as e:
            print(f"[-] API Fetching Error (Chunk {chunk}): {e}")
            break
            
    return files

def download_file(file_page_url, download_dir):
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
    try:
        res = requests.get(file_page_url, headers=headers)
        match = re.search(r'href="(https?://download\d+\.mediafire\.com/[^"]+)"', res.text)
        if match:
            direct_link = match.group(1)
            filename = direct_link.split('/')[-1]
            filepath = os.path.join(download_dir, filename)
            
            if os.path.exists(filepath):
                print(f"[⇄] Already exists: {filename}")
                return

            print(f"[+] Downloading: {filename}")
            with requests.get(direct_link, stream=True) as r:
                r.raise_for_status()
                with open(filepath, 'wb') as f:
                    for chunk in r.iter_content(chunk_size=1024*1024):
                        f.write(chunk)
            print(f"[✔] Downloaded: {filename}")
        else:
            print(f"[-] Direct link nahi mila: {file_page_url}")
    except Exception as e:
        print(f"[-] Error downloading {file_page_url}: {e}")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python ~/mf_folder.py <FOLDER_URL>")
        sys.exit(1)
        
    url = sys.argv[1]
    
    key_match = re.search(r'/folder/([a-zA-Z0-9]+)', url)
    if key_match:
        folder_key = key_match.group(1)
    else:
        folder_key = url.rstrip('/').split('/')[-1]
        
    print(f"[*] Folder Key: {folder_key}")
    
    download_dir = os.getcwd()
    print(f"[*] Saving files to: {download_dir}")
    
    links = get_all_folder_files(folder_key)
    if links:
        print(f"[+] Total files found: {len(links)}")
        print("[⚡] Turbo Boost Active: 15 Files ek sath parallel download ho rahi hain...\n")
        
        with ThreadPoolExecutor(max_workers=15) as executor:
            futures = [executor.submit(download_file, link, download_dir) for link in links]
            for future in futures:
                future.result()
    else:
        print("[-] API fail. Folder restricted ya khali hai.")
EOF

echo "[✔] Setup Complete! 15-thread Python script '~/mf_folder.py' ban chuki hai."
