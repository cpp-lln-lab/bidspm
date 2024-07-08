import re
import subprocess
from pathlib import Path

from update_versions_bug_report import main as update_bug_report

from utils import root_dir


def read_version_from_citation() -> str:
    with open(root_dir() / "CITATION.cff", encoding="utf-8") as file:
        for line in file:
            if line.startswith("version:"):
                version = line.strip().replace("version: ", "v")
                with open(
                    root_dir() / "version.txt", "w", encoding="utf-8"
                ) as version_file:
                    version_file.write(version)
                return version[1:]  # Remove the leading 'v'


def update_file(file_path, pattern, replacement):
    file_path = Path(file_path)
    content = file_path.read_text(encoding="utf-8")
    new_content = re.sub(pattern, replacement, content)
    file_path.write_text(new_content, encoding="utf-8")


def main():
    version = read_version_from_citation()

    if not version:
        print("Version not found in CITATION.cff")
        return

    update_file("README.md", r"version = {.*}", f"version = {{{version}}}")
    update_file("README.md", r"__version__ = .*", f"version = {{{version}}}")
    update_file(
        "src/reports/bidspm.bib", r"  version   = {.*}", f"  version   = {{{version}}}"
    )

    tools_dir = Path("tools")

    versions_txt_path = tools_dir / "versions.txt"
    versions = (
        subprocess.run(["git", "tag", "--list"], capture_output=True, text=True)
        .stdout.strip()
        .split("\n")[::-1]
    )
    versions_txt_path.write_text("\n".join(versions), encoding="utf-8")

    update_bug_report()

    print(f"Version updated to {version}")


if __name__ == "__main__":
    main()
