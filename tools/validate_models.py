import os
import re
from os import path
from os.path import join

import pydantic
from bsmschema.models import BIDSStatsModel
from rich import print


def validate_file(full_file_name):

    if re.findall("model-[]a-zA-Z0-9]*_smdl.json", full_file_name):

        try:
            BIDSStatsModel.parse_file(full_file_name)

        except pydantic.error_wrappers.ValidationError:
            print(f"[red]{full_file_name} is invalid.[/red]")

        else:
            print(f"[green]{full_file_name} is valid.[/green]")


def validate_dir(directory):
    for root, dirs, files in os.walk(directory):
        for name in files:
            full_file_name = join(root, name)
            validate_file(full_file_name)


def main():
    root_dir = path.abspath(join(path.dirname(__file__), ".."))

    demo_dir = join(root_dir, "demos")
    validate_dir(demo_dir)

    tests_dir = join(root_dir, "tests", "dummyData", "models")
    validate_dir(tests_dir)


if __name__ == "__main__":
    main()
