from __future__ import annotations

import ruamel.yaml

from utils import root_dir

yaml = ruamel.yaml.YAML()
yaml.indent(mapping=2, sequence=4, offset=2)


def main():
    bug_report = (root_dir / ".github" / "ISSUE_TEMPLATE" / "bug_report.yml").absolute()

    versions_file = (root_dir / "versions.txt").absolute()

    with open(bug_report, encoding="utf8") as input_file:
        content = yaml.load(input_file)

    with open(versions_file, encoding="utf8") as f:
        versions = f.read().splitlines()

    content["body"][7]["attributes"]["options"] = versions

    with open(bug_report, "w", encoding="utf-8") as output_file:
        yaml.dump(content, output_file)

    versions_file.unlink()


if __name__ == "__main__":
    main()
