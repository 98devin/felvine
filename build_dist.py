
from pathlib import Path
from argparse import ArgumentParser
import subprocess
import sys
from typing import List

parser = ArgumentParser()

parser.add_argument("--input-folder", type=Path, default=Path.cwd())
parser.add_argument("--output-folder", type=Path, default="dist")

args = parser.parse_args()

for path in args.input_folder.glob("*.fnl"):
    path: Path
    path_rel_name = path.relative_to(args.input_folder)
    out_path: Path = args.output_folder / path_rel_name
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.with_suffix(".lua").open("w") as out_file:
        subprocess.run(["fennel", "-c", path], stdout=out_file)