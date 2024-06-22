
from pathlib import Path
from argparse import ArgumentParser
import subprocess
import sys


class Batch:
    def __init__(self):
        self.proc_args = []

    def add(self, command, file):
        self.proc_args.extend([command, file])

    def run(self):
        return subprocess.run(["fennel", "felvine.fnl", *self.proc_args])


class Individual:
    def __init__(self):
        self.proc_args_list = []
    
    def add(self, command, file):
        self.proc_args_list.append([command, file])
    
    def run(self):
        failure_cases = []
        for proc_args in self.proc_args_list:
            try:
                subprocess.run(["fennel", "felvine.fnl", *proc_args]).check_returncode()
            except subprocess.CalledProcessError:
                failure_cases.append(proc_args)

        if len(failure_cases) == 0: return

        proportion_failed = len(failure_cases) / len(self.proc_args_list)
        print(f"Failed {len(failure_cases)}/{len(self.proc_args_list)} ({proportion_failed*100:.2f}%) of cases:", file=sys.stderr)
        for case in failure_cases:
            print(f"\t{case}", file=sys.stderr)

        sys.exit(1)


def validate(files):
    failure_cases = []
    for file in files:
        try:
            subprocess.run(["spirv-val", file]).check_returncode()
        except subprocess.CalledProcessError:
            failure_cases.append(file)

    if len(failure_cases) == 0: return

    proportion_failed = len(failure_cases) / len(files)
    print(f"Failed {len(failure_cases)}/{len(files)} ({proportion_failed*100:.2f}%) of cases:", file=sys.stderr)
    for case in failure_cases:
        print(f"\t{case}", file=sys.stderr)

    sys.exit(1)



parser = ArgumentParser()
parser.add_argument("--mode", type=str, choices=["batch", "cases"], default="cases")
parser.add_argument("--folder", type=Path, default="examples")
parser.add_argument("--bench", action="store_true")
parser.add_argument("--command", type=str, choices=["-c", "-t", "-S"], nargs="+", default=["-c"])

args = parser.parse_args()

times = 10 if args.bench else 1

case_collector = Individual()
if args.mode == "batch":
    case_collector = Batch()

files = list(args.folder.glob("**/*.fnl"))
print(f"Found: {' '.join(str(file) for file in files)}", file=sys.stderr)

for file in files:
    for command in args.command:
        for _ in range(times):
            case_collector.add(command, file)

case_collector.run()

if "-c" in args.command:
    validate(args.folder.glob("**/*.spv"))


