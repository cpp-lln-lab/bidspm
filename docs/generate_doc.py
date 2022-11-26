from __future__ import annotations

from pathlib import Path

code_src = Path(__file__).parent.parent.joinpath("src")

doc_src = Path(__file__).parent.joinpath("source")

bidspm_file = doc_src.joinpath("dev_doc.rst")

dir_ignore_list = ("__pycache__", "bidspm.egg-info", "workflows", "batches")

file_ignore_list = "BidsModel"


def append_dir_content(path, content, parent_folder=None):

    title = f"{path.name}" if parent_folder is None else f"{parent_folder} {path.name}"
    title.replace("_", " ")

    content += f"\n\n.. _{title}:\n"
    content += f"\n{title}\n"
    content += "=" * len(title) + "\n"

    m_files = path.glob("*.m")

    for file in m_files:

        if file.stem in file_ignore_list:
            continue

        content += f".. _{file.stem}:\n"
        if parent_folder is None:
            function_name = f"src.{path.name}.{file.stem}"
        else:
            function_name = f"src.{parent_folder}.{path.name}.{file.stem}"
        content += f".. autofunction:: {function_name}\n"

    return content


def main():

    with bidspm_file.open("w", encoding="utf8") as f:

        content = """.. AUTOMATICALLY GENERATED

.. _dev_doc:

developer documentation
***********************
"""

        content = append_dir_content(
            code_src.joinpath("workflows", "stats"), content, "workflows"
        )
        content = append_dir_content(
            code_src.joinpath("workflows", "preproc"), content, "workflows"
        )
        content = append_dir_content(
            code_src.joinpath("workflows", "lesion"), content, "workflows"
        )
        content = append_dir_content(
            code_src.joinpath("workflows", "roi"), content, "workflows"
        )
        content = append_dir_content(code_src.joinpath("workflows"), content)

        content = append_dir_content(
            code_src.joinpath("batches", "stats"), content, "batches"
        )
        content = append_dir_content(
            code_src.joinpath("batches", "preproc"), content, "batches"
        )
        content = append_dir_content(
            code_src.joinpath("batches", "lesion"), content, "batches"
        )
        content = append_dir_content(code_src.joinpath("batches"), content)

        for path in code_src.iterdir():

            if path.name in dir_ignore_list:
                continue

            if path.is_dir():

                content = append_dir_content(path, content)

        print(content, file=f)

    with bidspm_file.open("r", encoding="utf8") as f:
        content = f.read()

    print(content)


if __name__ == "__main__":
    main()
