import argparse
import logging
import sys
from pathlib import Path
from typing import Any

import pydantic
from bsmschema.models import BIDSStatsModel
from rich.logging import RichHandler

log = logging.getLogger("bidspm")


def bidspm_log(name: str = "bidspm") -> logging.Logger:
    """Create log."""

    FORMAT = "bidspm - %(asctime)s - %(levelname)s - %(message)s"

    if not name:
        name = "rich"

    logging.basicConfig(
        level="INFO", format=FORMAT, datefmt="[%X]", handlers=[RichHandler()]
    )

    return logging.getLogger(name)


def validate_parser():

    log = bidspm_log(name="bidspm")

    parser = argparse.ArgumentParser(
        description="validate bids stats model",
    )

    parser.add_argument(
        "model",
        help="""
        The bids stats model file. If a directory is provided,
        all files ending in '_smdl.json' will be validated.
        """,
        nargs=1,
    )

    return parser


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
