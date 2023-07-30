# replace PR numbers and github usernames with links
from __future__ import annotations

import re
from pathlib import Path

change_log = Path(__file__).parent.parent / "CHANGELOG.md"

with open(change_log) as f:
    lines = f.readlines()

with open(change_log, "w") as f:
    for line in lines:
        if match := re.search(r" @([a-zA-Z0-9_\-]+)", line):
            username = match[1]
            line = line.replace(
                match[0], f" by [{username}](https://github.com/{username}) "
            )

        if match := re.search(r"\#([0-9]+)", line):
            pr_number = match[1]
            line = line.replace(
                match[0],
                f"[{pr_number}](https://github.com/cpp-lln-lab/bidspm/pull/{pr_number})",
            )

        f.write(line)
