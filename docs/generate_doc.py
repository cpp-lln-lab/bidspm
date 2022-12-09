from __future__ import annotations

from pathlib import Path

from rich import print

code_src = Path(__file__).parent.parent.joinpath("src")

doc_src = Path(__file__).parent.joinpath("source")

bidspm_file = doc_src.joinpath("dev_doc.rst")

dir_ignore_list = ("__pycache__", "bidspm.egg-info", "workflows", "batches")

file_ignore_list = "BidsModel"


def return_title(path: Path, parent_folder=None):

    tmp = f"{path.name}" if parent_folder is None else f"{parent_folder} {path.name}"
    tmp.replace("_", " ")

    title = f"\n\n.. _{tmp}:\n"
    title += f"\n{tmp}\n"
    title += "=" * len(tmp) + "\n"

    return title


def append_dir_content(path: Path, content: str, parent_folder=None, recursive=False):

    if not path.is_dir():
        return content

    m_files = sorted(list(path.glob("*.m")))

    if len(m_files) > 0:
        title = return_title(path=path, parent_folder=parent_folder)
        content += title

    for file in m_files:

        if file.stem in file_ignore_list:
            continue

        content += f".. _{file.stem}:\n"
        if parent_folder is None:
            function_name = f"src.{path.name}.{file.stem}"
        else:
            function_name = f"src.{parent_folder}.{path.name}.{file.stem}"
        content += f".. autofunction:: {function_name}\n"

        print(function_name)

    if recursive and path.is_dir():
        print(path)
        for subpath in path.iterdir():
            content = append_dir_content(
                subpath, content, parent_folder=path.name, recursive=recursive
            )

    return content


def main():

    with bidspm_file.open("w", encoding="utf8") as f:

        content = """.. AUTOMATICALLY GENERATED

.. _dev_doc:

developer documentation
***********************
"""

        content = append_dir_content(
            code_src.joinpath("workflows"), content, parent_folder=None, recursive=True
        )
        content = append_dir_content(
            code_src.joinpath("batches"), content, parent_folder=None, recursive=True
        )

        subfolders = sorted(list(code_src.iterdir()))

        for path in subfolders:

            if path.name in dir_ignore_list:
                continue

            if path.is_dir():
                content = append_dir_content(
                    path, content, parent_folder=None, recursive=True
                )

        print(content, file=f)

    with bidspm_file.open("r", encoding="utf8") as f:
        content = f.read()

    # print(content)


if __name__ == "__main__":
    main()
