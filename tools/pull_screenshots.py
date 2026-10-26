from pathlib import Path
import json
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
adb = Path.home() / 'AppData/Local/Android/Sdk/platform-tools/adb.exe'
report = json.loads((root / 'docs/qa-report.json').read_text())
folder = report['screenshotsDirectory']
serial = sys.argv[1] if len(sys.argv) > 1 else 'emulator-5556'
base = [str(adb), '-s', serial, 'exec-out', 'run-as', 'com.crystalo.crystalo']
files = subprocess.check_output(base + ['ls', '-1', folder], text=True).splitlines()
for name in files:
    if not name.endswith('.png') or '/' in name or '\\' in name:
        continue
    data = subprocess.check_output(base + ['cat', folder + '/' + name])
    (root / 'docs/screenshots' / name).write_bytes(data)
print(f'Saved {len(files)} Android screenshots.')
