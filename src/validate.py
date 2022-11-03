import sys
from pathlib import Path
from typing import Any

import pydantic
from bsmschema.models import BIDSStatsModel

from src.parsers import bidspm_log
from src.parsers import validate_parser

log = bidspm_log(name="bidspm")


def validate(file: Path) -> None:
    file = file.absolute()
    log.info(f"Validating {file}")
    try:
        BIDSStatsModel.parse_file(file)
    except pydantic.error_wrappers.ValidationError as e:
        log.warning(
            f"""{file} is not a valid BIDS Stats Model file.
    Please use the validator: https://bids-standard.github.io/stats-models/validator.html"""
        )
        log.warning(e)
        sys.exit(1)


def main(argv: Any = sys.argv) -> None:

    parser = validate_parser()
    args = parser.parse_args(argv[1:])

    input_ = Path(args.model[0])

    if not input_.exists():
        raise FileNotFoundError(f"{input_} does not exist.")

    elif input_.is_file():
        validate(input_)

    if input_.is_dir():
        for file in input_.glob("*_smdl.json"):
            validate(file)


if __name__ == "__main__":
    main()
