#!/usr/bin/env python3
"""Compile the actual reference fences and matching runtime into a new directory.

Requires the selected Hoot compiler on PATH (or HOOT). Does not fetch tools or
start a server. Generated sources and binaries remain in the supplied output.
"""
import argparse
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def fences(name, language):
    text = (ROOT / "references" / name).read_text(encoding="utf-8")
    return re.findall(r"```" + language + r"\n(.*?)```", text, re.S)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path, help="A new, nonexistent directory")
    args = parser.parse_args()
    if sys.version_info < (3, 10):
        parser.error("Python 3.10 or newer is required")
    try:
        hoot = shlex.split(os.environ.get("HOOT", "hoot"))
    except ValueError as error:
        parser.error(f"Invalid HOOT: {error}")
    if not hoot or shutil.which(hoot[0]) is None:
        parser.error("HOOT: executable not found; select the declared Hoot environment")
    output = args.output.resolve()
    output.mkdir(parents=True)
    (output / "example").mkdir()
    scheme = fences("host-examples.md", "scheme")
    for name, source in zip(("example/preview.scm", "example/status.scm",
                             "browser-main.scm"), scheme[:3], strict=True):
        (output / name).write_text(source, encoding="utf-8")
    (output / "host-work.scm").write_text(fences("host-promises.md", "scheme")[0], encoding="utf-8")
    adapter = fences("host-examples.md", "javascript")[0]
    (output / "adapter.mjs").write_text(adapter + "\nexport { mountStatus };\n", encoding="utf-8")
    policy = fences("interaction-state.md", "scheme")[0]
    policy = policy.replace("(import (scheme base))", "", 1).strip()
    (output / "example/action-owner.scm").write_text(
        "(library (example action-owner) (export make-action-owner) "
        "(import (scheme base))\n" + policy + "\n)\n", encoding="utf-8")
    shutil.copy2(ROOT / "examples/browser-probe/action.scm", output / "action.scm")
    for name in ("browser-main", "host-work", "action"):
        subprocess.run(hoot + ["compile", "-L", str(output),
                        "--bundle", "-o", str(output / (name + ".wasm")),
                        str(output / (name + ".scm"))], check=True, timeout=180)
    for source in (ROOT / "examples/browser-probe").iterdir():
        shutil.copy2(source, output / source.name)
    print("Built browser probe: " + str(output / "index.html"))


if __name__ == "__main__":
    main()
