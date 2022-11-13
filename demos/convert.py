"""Convert Octave notebooks to scripts."""
import json
from pathlib import Path

from rich import print

this_dir = Path(__file__).parent

notebooks = this_dir.glob("**/*.ipynb")

for ntbk in notebooks:

    with open(ntbk) as f:
        nb = json.load(f)

    filename = ntbk.stem.replace("-", "_")

    output_file = ntbk.with_stem(filename).with_suffix(".m")

    with open(output_file, "w") as f:

        for cell in nb["cells"]:

            if cell["cell_type"] == "markdown":
                for i, line in enumerate(cell["source"]):
                    line = line.rstrip()
                    ending = "\n"
                    if i == len(cell["source"]) - 1:
                        ending = ""
                    if line == "":
                        print("%", file=f)
                    else:
                        print(f"% {line.rstrip()}{ending}", file=f, end="")

            if cell["cell_type"] == "code":
                for i, line in enumerate(cell["source"]):
                    line = line.rstrip()
                    ending = "\n"
                    if i == len(cell["source"]) - 1:
                        ending = ""
                    if line == "":
                        print("", file=f)
                    elif not line.endswith(";") and not line.endswith("..."):
                        print(f"{line.rstrip()};{ending}", file=f, end="")
                    else:
                        print(f"{line.rstrip()}{ending}", file=f, end="")

            print(
                "\n",
                file=f,
            )
