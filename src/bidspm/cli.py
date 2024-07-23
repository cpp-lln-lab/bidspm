#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any

from .bidspm import bidspm
from .parsers import ALLOWED_ACTIONS, bidspm_log, sub_command_parser

log = bidspm_log(name="bidspm")

NOT_IMPLEMENTED = {
    "bms",
    "bms-bms",
    "bms-posterior",
    "copy",
    "specify_only",
}

with open(Path(__file__).parent / "data" / "exit_codes.json") as f:
    EXIT_CODES = json.load(f)

SUPPORTED_ACTIONS = set(ALLOWED_ACTIONS) - NOT_IMPLEMENTED


ul_it = "\n\t- "


def validate_actions(action: str) -> None:
    if action not in ALLOWED_ACTIONS:
        log.error(
            f"Unknown action: '{action}'."
            "\nSupported actions are:"
            f"{ul_it}{ul_it.join(SUPPORTED_ACTIONS)}"
        )
        raise SystemExit(EXIT_CODES["USAGE"]["Value"])

    if action in NOT_IMPLEMENTED:
        log.error(
            f"The action '{action}' is not yet implemented."
            "\nSupported actions are:"
            f"{ul_it}{ul_it.join(SUPPORTED_ACTIONS)}"
        )
        raise SystemExit(EXIT_CODES["USAGE"]["Value"])


def cli(argv: Any = sys.argv) -> None:
    parser = sub_command_parser()

    args = parser.parse_args(argv[1:])

    bids_dir = Path(args.bids_dir[0]).absolute()
    output_dir = Path(args.output_dir[0]).absolute()
    analysis_level = args.analysis_level[0]

    command = args.command
    validate_actions(command)

    bids_filter_file = (
        Path(args.bids_filter_file[0]).absolute()
        if args.bids_filter_file is not None
        else None
    )

    options: Path | None = (
        Path(args.options).absolute() if args.options is not None else None
    )

    preproc_dir: Path | None = None
    if preproc_dir := getattr(args, "preproc_dir", None):
        preproc_dir = (
            Path(args.preproc_dir[0]).absolute() if args.preproc_dir is not None else None
        )
    if preproc_dir is not None and not preproc_dir.is_dir():
        log.error("The 'preproc_dir' does not exist:\n\t" f"{preproc_dir}")
        exit(EXIT_CODES["NOINPUT"]["Value"])

    if command in {"stats", "contrasts", "results", "default_model"} and (
        args.space and len(args.space) > 1
    ):
        log.error(
            "Only one space allowed for statistical analysis.\n" f"Got: {args.space}"
        )
        raise SystemExit(EXIT_CODES["USAGE"]["Value"])

    model_file: Path | None = None
    if model_file := getattr(args, "model_file", None):
        model_file: Path | None = (
            Path(args.model_file[0]).absolute() if args.model_file is not None else None
        )

    if not bids_dir.is_dir():
        log.error("The 'bids_dir' does not exist:\n\t" f"{bids_dir}")
        exit(EXIT_CODES["NOINPUT"]["Value"])

    if command == "default_model":
        return_code = bidspm(
            bids_dir=bids_dir,
            output_dir=output_dir,
            analysis_level=analysis_level,
            action=command,
            verbosity=args.verbosity,
            task=args.task,
            space=args.space,
            ignore=args.ignore,
            options=options,
            skip_validation=args.skip_validation,
        )

    elif command == "create_roi":
        return_code = bidspm(
            bids_dir=bids_dir,
            output_dir=output_dir,
            action=command,
            preproc_dir=preproc_dir,
            verbosity=args.verbosity,
            participant_label=args.participant_label,
            roi_dir=args.roi_dir,
            roi_atlas=args.roi_atlas[0],
            roi_name=args.roi_name,
            space=args.space,
            bids_filter_file=bids_filter_file,
            options=options,
        )

    elif command in {"preprocess", "smooth"}:
        if command == "preprocess" and args.task and len(args.task) > 1:
            log.error("Only one task allowed for preprocessing.\n" f"Got: {args.task}")
            raise SystemExit(EXIT_CODES["USAGE"]["Value"])

        return_code = bidspm(
            bids_dir=bids_dir,
            output_dir=output_dir,
            action=command,
            participant_label=args.participant_label,
            verbosity=args.verbosity,
            task=args.task,
            space=args.space,
            ignore=args.ignore,
            fwhm=args.fwhm,
            dummy_scans=args.dummy_scans,
            skip_validation=args.skip_validation,
            anat_only=args.anat_only,
            bids_filter_file=bids_filter_file,
            dry_run=args.dry_run,
            options=options,
        )

    if return_code == 1:
        raise SystemExit(EXIT_CODES["FAILURE"]["Value"])
    else:
        sys.exit(EXIT_CODES["SUCCESS"]["Value"])


def new_cli(argv: Any = sys.argv) -> None:

    parser = sub_command_parser()

    args, _ = parser.parse_known_args(argv[1:])
