from __future__ import annotations

from pathlib import Path

from rich import print

code_src = Path(__file__).parent.parent.joinpath("src")

doc_src = Path(__file__).parent.joinpath("source")

bidspm_file = doc_src.joinpath("API.rst")

dir_ignore_list = ("__pycache__", "bidspm.egg-info", "workflows", "batches")

file_ignore_list = "BidsModel"


def return_title(path: Path, level=1):
    tmp = f"{path.name}"
    tmp.replace("_", " ")

    if level == 1:
        string = "="
    if level > 1:
        string = "-"

    title = f"\n{tmp}\n"
    title += string * len(tmp) + "\n"

    return title


def append_dir_content(path: Path, content: str, recursive=False, level=1):
    if not path.is_dir():
        return content

    m_files = sorted(list(path.glob("*.m")))

    title = return_title(path=path, level=level)
    content += title

    for file in m_files:
        if file.stem in file_ignore_list:
            continue

        function_name = file.relative_to(code_src.parent).as_posix()
        content += f".. autofunction:: {function_name}\n"

        print(function_name)

    if recursive and path.is_dir():
        print(path)
        for subpath in path.iterdir():
            content = append_dir_content(
                subpath,
                content,
                recursive=recursive,
                level=level + 1,
            )

    return content


def update_content(old_content, f):
    for line in old_content:
        if line.startswith(".. AUTOMATICALLY GENERATED"):
            break
        print(line.strip("\n"), file=f)
    content = """.. AUTOMATICALLY GENERATED
"""

    content = append_dir_content(code_src.joinpath("workflows"), content, recursive=True)
    content = append_dir_content(code_src.joinpath("batches"), content, recursive=True)

    subfolders = sorted(list(code_src.iterdir()))

    for path in subfolders:
        if path.name in dir_ignore_list:
            continue

        if path.is_dir():
            content = append_dir_content(path, content, recursive=True)

    print(content, file=f)

    # print(content)


def main():
    with bidspm_file.open("r", encoding="utf8") as f:
        old_content = f.readlines()

    with bidspm_file.open("w", encoding="utf8") as f:
        update_content(old_content, f)


if __name__ == "__main__":
    main()
