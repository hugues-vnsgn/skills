#!/usr/bin/env python3
"""Compile and test the current skill example in an isolated temporary project."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from datetime import datetime, timezone

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gradle', default='gradle', help='Gradle executable (tested with 8.14.4)')
args = parser.parse_args()
here = Path(__file__).resolve().parent
repo = here.parents[2]
package = repo / 'skills/house/mobile/kmp-ktor'
reference = package / 'client-reference.md'
blocks = re.findall(r'```kotlin\n(.*?)\n```', reference.read_text(), re.S)
factory = [b for b in blocks if 'fun createApiClient(' in b]
if len(factory) != 1:
    raise SystemExit('Expected one concrete createApiClient block')
workspace = Path(tempfile.mkdtemp(prefix='mobile-ktor-fixture-'))
shutil.copytree(here / 'ktor', workspace, dirs_exist_ok=True)
(workspace / 'src/main/kotlin/Client.kt').write_text(factory[0] + '\n')
metadata = {
    'started_at_utc': datetime.now(timezone.utc).isoformat(),
    'package_files': {str(p.relative_to(package)): hashlib.sha256(p.read_bytes()).hexdigest()
                      for p in sorted(package.rglob('*')) if p.is_file()},
    'command': [args.gradle, '--no-daemon', 'test'],
    'scope': 'JVM compilation and MockEngine behavior; no native engine or live API verification',
}
print(f'Fixture and evidence: {workspace}', flush=True)
with (workspace / 'output.txt').open('w') as log:
    result = subprocess.run(metadata['command'], cwd=workspace, stdout=log, stderr=subprocess.STDOUT)
metadata['exit_code'] = result.returncode
metadata['finished_at_utc'] = datetime.now(timezone.utc).isoformat()
(workspace / 'metadata.json').write_text(json.dumps(metadata, indent=2) + '\n')
print((workspace / 'output.txt').read_text())
raise SystemExit(result.returncode)
