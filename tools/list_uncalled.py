from pathlib import Path

from rich import print

from utils import root_dir


def find_files_with_extension(directory, extension):
    """Recursively find all files in directory with the given extension."""
    return list(Path(directory).rglob(f"*{extension}"))


def main():
    src_folder = root_dir() / "src"
    files = find_files_with_extension(src_folder, ".m")

    for file in files:
        function = file.stem

        occurrences = []
        for other_file in files:
            with open(other_file, encoding="utf-8") as f:
                content = f.read()
                if function in content:
                    occurrences.append(f"{other_file}:{content.find(function)}")

        nb_lines = len(occurrences)

        if nb_lines < 2:
            print(
                "\n---------------------------------------------------------------------"
            )
            print(function)
            print()
            for line in occurrences:
                print(line)


if __name__ == "__main__":
    main()
