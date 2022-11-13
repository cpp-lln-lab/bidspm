#!/usr/bin/env python3
import sys

from src.parsers import default_model_parser
from src.parsers import low_parser
from src.parsers import preproc_parser
from src.parsers import stats_parser


def low(argv=sys.argv) -> None:

    parser = low_parser()

    args = parser.parse_args(argv[1:])


def default_model(argv=sys.argv) -> None:

    parser = default_model_parser()

    args = parser.parse_args(argv[1:])


def stats(argv=sys.argv) -> None:

    parser = stats_parser()

    args = parser.parse_args(argv[1:])


def preproc(argv=sys.argv) -> None:

    parser = preproc_parser()

    args = parser.parse_args(argv[1:])


def main(argv=sys.argv) -> None:

    parser = preproc_parser()

    args = parser.parse_args(argv[1:])


if __name__ == "__main__":
    main()
