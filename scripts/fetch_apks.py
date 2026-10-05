import os
import json
import urllib.request
import time

def fetch():
    url = 'https://api.github.com/repos/nirrjhorr/Firefly/releases/tags/v1.0.0'
    req = urllib.request.Request(url, headers={'User-Agent': 'Firefly-Sideload'})
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode())
    
    os.makedirs('dist', exist_ok=True)
    for asset in data.get('assets', []):
        name = asset['name']
        if name.endswith('.apk'):
            dl_url = asset['browser_download_url']
            size_mb = asset['size'] / 1024 / 1024
            dest = os.path.join('dist', name)
            print(f"Downloading {name} ({size_mb:.2f} MB)...")
            start = time.time()
            urllib.request.urlretrieve(dl_url, dest)
            print(f"Downloaded {dest} in {time.time() - start:.1f}s (Actual size: {os.path.getsize(dest) / 1024 / 1024:.2f} MB)")

if __name__ == '__main__':
    fetch()
