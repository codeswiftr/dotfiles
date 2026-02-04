import argparse
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--include', nargs='*', default=[])
parser.add_argument('--output', default='repomix-summary.txt')
args = parser.parse_args()

command = ['npx', '--yes', 'repomix@latest', '--no-gitignore', '.']
for pattern in args.include:
    command.extend(['--include', pattern])

output = Path(args.output)
with output.open('w', encoding='utf-8') as handle:
    subprocess.run(command, check=True, stdout=handle)

print(f"repomix summary written to {output}")
