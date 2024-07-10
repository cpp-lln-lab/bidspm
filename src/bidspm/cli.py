#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any

from .bidspm import bidspm
from .parsers import ALLOWED_ACTIONS, bidspm_log, common_parser

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
    parser = common_parser()

    args, _ = parser.parse_known_args(argv[1:])

    bids_dir = Path(args.bids_dir[0]).absolute()
    output_dir = Path(args.output_dir[0]).absolute()
    analysis_level = args.analysis_level[0]
    action = args.action[0]
    roi_atlas = args.roi_atlas[0]
    bids_filter_file = (
        Path(args.bids_filter_file[0]).absolute()
        if args.bids_filter_file is not None
        else None
    )

    preproc_dir: Path | None = (
        Path(args.preproc_dir[0]).absolute() if args.preproc_dir is not None else None
    )
    model_file: Path | None = (
        Path(args.model_file[0]).absolute() if args.model_file is not None else None
    )
    options: Path | None = (
        Path(args.options).absolute() if args.options is not None else None
    )

    space = args.space

    task = args.task

    validate_actions(action)

    if not bids_dir.is_dir():
        log.error("The 'bids_dir' does not exist:\n\t" f"{bids_dir}")
        exit(EXIT_CODES["NOINPUT"]["Value"])

    if preproc_dir is not None and not preproc_dir.is_dir():
        log.error("The 'preproc_dir' does not exist:\n\t" f"{preproc_dir}")
        exit(EXIT_CODES["NOINPUT"]["Value"])

    if action in {"stats", "contrasts", "results"}:
        if preproc_dir is None or not preproc_dir.exists():
            log.error(
                "'preproc_dir' must be specified for stats.\n" f"Got: {preproc_dir}"
            )
            raise SystemExit(EXIT_CODES["USAGE"]["Value"])

        if model_file is None or not model_file.exists():
            log.error("'model_file' must be specified for stats.\n" f"Got: {model_file}")
            raise SystemExit(EXIT_CODES["USAGE"]["Value"])

    if action in {"stats", "contrasts", "results", "default_model"} and (
        space and len(space) > 1
    ):
        log.error("Only one space allowed for statistical analysis.\n" f"Got: {space}")
        raise SystemExit(EXIT_CODES["USAGE"]["Value"])

    if action == "preprocess" and task and len(task) > 1:
        log.error("Only one task allowed for preprocessing.\n" f"Got: {task}")
        raise SystemExit(EXIT_CODES["USAGE"]["Value"])

    return_code = bidspm(
        bids_dir,
        output_dir,
        analysis_level,
        action=action,
        participant_label=args.participant_label,
        verbosity=args.verbosity,
        task=task,
        space=space,
        ignore=args.ignore,
        fwhm=args.fwhm,
        bids_filter_file=bids_filter_file,
        dummy_scans=args.dummy_scans,
        anat_only=args.anat_only,
        skip_validation=args.skip_validation,
        dry_run=args.dry_run,
        preproc_dir=preproc_dir,
        model_file=model_file,
        roi_based=args.roi_based,
        roi_atlas=roi_atlas,
        roi_name=args.roi_name,
        roi_dir=args.roi_dir,
        concatenate=args.concatenate,
        design_only=args.design_only,
        keep_residuals=args.keep_residuals,
        options=options,
    )

    if return_code == 1:
        raise SystemExit(EXIT_CODES["FAILURE"]["Value"])
    else:
        sys.exit(EXIT_CODES["SUCCESS"]["Value"])
