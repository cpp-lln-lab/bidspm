from __future__ import annotations

import sys
from pathlib import Path
from typing import Any

import pydantic
from bsmschema.models import BIDSStatsModel

from .parsers import bidspm_log, validate_parser

log = bidspm_log(name="bidspm")


def validate(file: Path) -> int:
    file = file.absolute()
    log.info(f"Validating {file}")
    try:
        BIDSStatsModel.parse_file(file)
        return 0
    except pydantic.error_wrappers.ValidationError as e:
        log.warning(
            f"""{file} is not a valid BIDS Stats Model file.
    Please use the validator: https://bids-standard.github.io/stats-models/validator.html"""
        )
        log.warning(e)
        return 1


def main(input: Path) -> int:
    if not input.exists():
        raise FileNotFoundError(f"{input} does not exist.")

    if input.is_file():
        log.info(f"Validating {input}")
        global_status = validate(input)

    elif input.is_dir():
        global_status = 0
        for file in input.glob("*_smdl.json"):
            return_code = validate(file)
            if return_code == 1:
                global_status = 1

    return global_status


def cli(argv: Any = sys.argv) -> None:
    parser = validate_parser()
    args = parser.parse_args(argv[1:])
    input_ = Path(args.model[0]).resolve()
    return_code = main(input=input_)
    sys.exit(return_code)


if __name__ == "__main__":
    cli(sys.argv)
