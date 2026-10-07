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
headers = {'Authorization': f'token {token}', 'Accept': 'application/vnd.github.v3+json', 'User-Agent': 'CI'}

req = urllib.request.Request('https://api.github.com/repos/nirrjhorr/Firefly/actions/runs?per_page=6', headers=headers)
with urllib.request.urlopen(req) as resp:
    data = json.loads(resp.read().decode())
    for r in data['workflow_runs']:
        rid = r['id']
        name = r.get('name')
        event = r.get('event')
        status = r.get('status')
        conclusion = r.get('conclusion')
        sha = r.get('head_sha', '')[:7]
        print(f"Run {rid}: {name} (event: {event}) - status: {status}, conclusion: {conclusion}, sha: {sha}")
        req_jobs = urllib.request.Request(f'https://api.github.com/repos/nirrjhorr/Firefly/actions/runs/{rid}/jobs', headers=headers)
        with urllib.request.urlopen(req_jobs) as jresp:
            jdata = json.loads(jresp.read().decode())
            for job in jdata.get('jobs', []):
                print(f"  Job {job['name']}: {job['status']} ({job.get('conclusion')})")
                for step in job.get('steps', []):
                    if step.get('conclusion') == 'failure' or step['status'] != 'completed':
                        print(f"    Step: {step['name']} -> {step['status']} ({step.get('conclusion')})")
