#!/bin/bash
# Push to GitHub via API (bypasses corporate firewall git protocol block)
# Token stored in git config: git config pomodoronotch.token "ghp_xxx"
set -e
cd "$(dirname "$0")/.."

TOKEN=$(git config pomodoronotch.token)
[ -z "$TOKEN" ] && { echo "Set token first: git config pomodoronotch.token ghp_xxx"; exit 1; }

REPO="raymondjxj/PomodoroNotch"
API="https://api.github.com/repos/${REPO}"

# Detect changed files (unstaged + staged + last commit)
FILES=$( { git diff --name-only; git diff --cached --name-only; git diff --name-only HEAD~1 2>/dev/null; } | sort -u | grep -v '^$')
[ -z "$FILES" ] && { echo "No changes."; exit 0; }

MSG="${1:-Update $(echo "$FILES" | wc -l | tr -d ' ') files}"

python3 << PYEOF
import json, urllib.request, os

TOKEN = """${TOKEN}""".strip()
FILES = """${FILES}""".strip().split("\n")
MSG = """${MSG}""".strip()
API = "https://api.github.com/repos/${REPO}"
HEADERS = {"Authorization": f"token {TOKEN}", "Content-Type": "application/json"}

def req(method, url, data=None):
    if data: data = json.dumps(data).encode()
    r = urllib.request.Request(url, data=data, headers=HEADERS, method=method)
    return json.loads(urllib.request.urlopen(r).read())

head = req("GET", f"{API}/git/refs/heads/main")["object"]["sha"]
base_tree = req("GET", f"{API}/git/commits/{head}")["tree"]["sha"]

entries = []
for f in FILES:
    f = f.strip()
    if not f or not os.path.isfile(f): continue
    with open(f) as fh: content = fh.read()
    sha = req("POST", f"{API}/git/blobs", {"content": content, "encoding": "utf-8"})["sha"]
    entries.append({"path": f, "mode": "100755" if f.endswith(".sh") else "100644", "type": "blob", "sha": sha})
    print(f"  {f}: {sha[:8]}")

new_tree = req("POST", f"{API}/git/trees", {"base_tree": base_tree, "tree": entries})["sha"]
commit = req("POST", f"{API}/git/commits", {"message": MSG, "tree": new_tree, "parents": [head]})["sha"]
req("PATCH", f"{API}/git/refs/heads/main", {"sha": commit})
print(f"Pushed: {commit[:8]}")
os.system("git fetch origin && git reset --hard origin/main")
PYEOF
echo "Done."
