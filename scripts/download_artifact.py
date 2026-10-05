import os
import sys
import json
import zipfile
import io
import subprocess
import urllib.request

def get_token():
    p = subprocess.Popen(['git', 'credential', 'fill'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    stdout, _ = p.communicate('protocol=https\nhost=github.com\n\n')
    for line in stdout.splitlines():
        if line.startswith('password='):
            return line.split('=', 1)[1]
    return ''

class NoAuthRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        new_req = super().redirect_request(req, fp, code, msg, headers, newurl)
        if new_req and 'Authorization' in new_req.headers:
            del new_req.headers['Authorization']
        return new_req

def download_run_artifacts(run_id=None):
    token = get_token()
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'Firefly-Artifact-Downloader'
    }

    if not run_id:
        req_runs = urllib.request.Request('https://api.github.com/repos/nirrjhorr/Firefly/actions/runs', headers=headers)
        with urllib.request.urlopen(req_runs) as resp:
            runs_data = json.loads(resp.read().decode())
            run_id = str(runs_data['workflow_runs'][0]['id'])

    print(f"Checking artifacts for Run ID: {run_id}...")
    req_art = urllib.request.Request(f'https://api.github.com/repos/nirrjhorr/Firefly/actions/runs/{run_id}/artifacts', headers=headers)
    with urllib.request.urlopen(req_art) as resp:
        data = json.loads(resp.read().decode())
        artifacts = data.get('artifacts', [])

    if not artifacts:
        print("No artifacts found for this run yet.")
        return False

    opener = urllib.request.build_opener(NoAuthRedirect)

    for art in artifacts:
        name = art['name']
        art_id = art['id']
        size = art['size_in_bytes']
        print(f"Found artifact: {name} (ID: {art_id}, {size / 1024 / 1024:.2f} MB)")

        download_url = f"https://api.github.com/repos/nirrjhorr/Firefly/actions/artifacts/{art_id}/zip"
        req_dl = urllib.request.Request(download_url, headers={
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'Firefly-Artifact-Downloader'
        })

        print("Downloading artifact...")
        with opener.open(req_dl) as dl_resp:
            zip_bytes = dl_resp.read()

        os.makedirs('dist', exist_ok=True)
        with zipfile.ZipFile(io.BytesIO(zip_bytes)) as z:
            for item in z.namelist():
                out_path = os.path.join('dist', item)
                with open(out_path, 'wb') as f:
                    f.write(z.read(item))
                print(f"Extracted: {out_path} ({os.path.getsize(out_path) / 1024 / 1024:.2f} MB)")

    return True

if __name__ == '__main__':
    run_arg = sys.argv[1] if len(sys.argv) > 1 else None
    download_run_artifacts(run_arg)
