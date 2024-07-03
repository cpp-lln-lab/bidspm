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


def main(argv: Any = sys.argv) -> None:
    parser = validate_parser()
    args = parser.parse_args(argv[1:])

    input_ = Path(args.model[0])

    if not input_.exists():
        raise FileNotFoundError(f"{input_} does not exist.")

    elif input_.is_file():
        log.info(f"Validating {input_}")
        return_code = validate(input_)
        sys.exit(return_code)

    if input_.is_dir():
        global_status = 0
        for file in input_.glob("*_smdl.json"):
            return_code = validate(file)
            if return_code == 1:
                global_status = 1
        sys.exit(global_status)


if __name__ == "__main__":
    main()
