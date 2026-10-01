import os
import json
import urllib.request
import urllib.error

TOKEN = os.environ.get('GITHUB_TOKEN', '')
REPO = os.environ.get('GITHUB_REPOSITORY', 'nirrjhorr/Firefly')
TAG = os.environ.get('RELEASE_TAG', 'v1.0.0')

def github_request(url, method='GET', data=None, headers=None):
    req_headers = {
        'Authorization': f'token {TOKEN}',
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'Firefly-Release-Publisher',
    }
    if headers:
        req_headers.update(headers)
    
    body = None
    if data is not None:
        if isinstance(data, (dict, list)):
            body = json.dumps(data).encode('utf-8')
            req_headers['Content-Type'] = 'application/json'
        elif isinstance(data, bytes):
            body = data
        elif isinstance(data, str):
            body = data.encode('utf-8')
    
    req = urllib.request.Request(url, data=body, headers=req_headers, method=method)
    return urllib.request.urlopen(req)

def get_or_create_release():
    # Check if release exists
    try:
        with github_request(f'https://api.github.com/repos/{REPO}/releases/tags/{TAG}') as resp:
            data = json.loads(resp.read().decode())
            print(f"Existing release found: ID {data['id']}")
            return data
    except urllib.error.HTTPError as e:
        if e.code != 404:
            raise

    # Read release notes
    notes_path = os.path.join('dist', 'RELEASE_NOTES.md')
    body = "Firefly v1.0.0 — Official Production Release"
    if os.path.exists(notes_path):
        with open(notes_path, 'r', encoding='utf-8') as f:
            body = f.read()

    payload = {
        'tag_name': TAG,
        'target_commitish': 'main',
        'name': 'Firefly v1.0.0 — Official Production Release',
        'body': body,
        'draft': False,
        'prerelease': False
    }

    with github_request(f'https://api.github.com/repos/{REPO}/releases', method='POST', data=payload) as resp:
        data = json.loads(resp.read().decode())
        print(f"Created new release: ID {data['id']}, URL: {data['html_url']}")
        return data

def upload_asset(release, file_path, content_type):
    file_name = os.path.basename(file_path)
    upload_url = release['upload_url'].split('{')[0] + f'?name={file_name}'

    # Check if asset already exists in release
    existing_assets = release.get('assets', [])
    for a in existing_assets:
        if a['name'] == file_name:
            print(f"Asset '{file_name}' already exists (ID {a['id']}), deleting first to replace...")
            try:
                del_req = urllib.request.Request(
                    a['url'],
                    headers={
                        'Authorization': f'token {TOKEN}',
                        'Accept': 'application/vnd.github.v3+json',
                        'User-Agent': 'Firefly-Release-Publisher'
                    },
                    method='DELETE'
                )
                urllib.request.urlopen(del_req)
            except Exception as e:
                print(f"Warning deleting old asset: {e}")

    with open(file_path, 'rb') as f:
        file_bytes = f.read()

    headers = {
        'Content-Type': content_type,
        'Content-Length': str(len(file_bytes))
    }

    print(f"Uploading {file_name} ({len(file_bytes)} bytes)...")
    with github_request(upload_url, method='POST', data=file_bytes, headers=headers) as resp:
        asset_data = json.loads(resp.read().decode())
        print(f"Successfully uploaded {file_name}: {asset_data['browser_download_url']}")
        return asset_data

def main():
    print(f"Publishing GitHub Release for {REPO} at tag {TAG}...")
    release = get_or_create_release()

    assets_to_upload = [
        (os.path.join('dist', 'firefly-v1.0.0-release.apk'), 'application/vnd.android.package-archive'),
        (os.path.join('dist', 'firefly-v1.0.0-debug.apk'), 'application/vnd.android.package-archive'),
        (os.path.join('dist', 'checksums.json'), 'application/json'),
        (os.path.join('dist', 'INSTALL.md'), 'text/markdown'),
    ]

    for path, ctype in assets_to_upload:
        if os.path.exists(path):
            upload_asset(release, path, ctype)
        else:
            print(f"Skipping missing asset: {path}")

    print("\nRelease is live!")
    print(f"Release page: {release['html_url']}")

if __name__ == '__main__':
    main()
