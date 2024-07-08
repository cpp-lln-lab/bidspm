"""Update CITATION.cff file."""

from __future__ import annotations

from pathlib import Path
from typing import Any

import ruamel.yaml

from utils import root_dir

yaml = ruamel.yaml.YAML()
yaml.indent(mapping=2, sequence=4, offset=2)


def citation_file() -> Path:
    """Return path to CITATIONS.cff file."""
    return root_dir() / "CITATION.cff"


def read_citation_cff() -> dict[str, Any]:
    """Read CITATION.cff file."""
    print(f"Reading file: {citation_file()}")
    with open(citation_file(), encoding="utf8") as f:
        citation = yaml.load(f)
    return citation


def write_citation_cff(citation: dict[str, Any]) -> None:
    """Write CITATION.cff file."""
    print(f"Writing file: {citation_file()}")
    with open(citation_file(), "w", encoding="utf8") as f:
        yaml.dump(citation, f)


def sort_authors(authors: list[dict[str, str]]) -> list[dict[str, str]]:
    """Sort authors by given name."""
    print(" Sorting authors by given name")
    authors.sort(key=lambda x: x["given-names"])
    return authors


def main() -> None:
    """Update names.rst and AUTHORS.rst files."""
    citation = read_citation_cff()
    citation["authors"] = sort_authors(citation["authors"])
    write_citation_cff(citation)


if __name__ == "__main__":
    main()
