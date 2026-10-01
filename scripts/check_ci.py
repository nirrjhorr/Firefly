import subprocess
import urllib.request
import json
import sys

def get_token():
    p = subprocess.Popen(['git', 'credential', 'fill'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    stdout, _ = p.communicate('protocol=https\nhost=github.com\n\n')
    for line in stdout.splitlines():
        if line.startswith('password='):
            return line.split('=', 1)[1]
    return ''

token = get_token()
headers = {
    'Authorization': f'token {token}',
    'Accept': 'application/vnd.github.v3+json',
    'User-Agent': 'Firefly-CI-Monitor'
}

run_id = sys.argv[1] if len(sys.argv) > 1 else '36836092912'
req = urllib.request.Request(f'https://api.github.com/repos/nirrjhorr/Firefly/actions/runs/{run_id}/jobs', headers=headers)

try:
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode())
        steps = data['jobs'][0]['steps']
        print(f"{'Step Name':<55} {'Status':<12} {'Conclusion':<10}")
        print("-" * 80)
        for s in steps:
            print(f"{s['name']:<55} {s['status']:<12} {str(s.get('conclusion')):<10}")
except Exception as e:
    print('Error:', e)
