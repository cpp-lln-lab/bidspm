#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path
from typing import Any

from rich import print

from .bidspm import (
    generate_command_bms,
    generate_command_contrasts,
    generate_command_create_roi,
    generate_command_default_model,
    generate_command_preprocess,
    generate_command_results,
    generate_command_smooth,
    generate_command_stats,
    new_line,
)
from .matlab import matlab
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


def cli(argv: Any = sys.argv) -> None:
    parser = sub_command_parser()

    args = parser.parse_args(argv[1:])

    _validate_bids_dir(args)
    _validate_analysis_level(args)
    _validate_actions(args.command)
    _validate_task(args)
    _validate_space(args)

    if args.command == "default_model":
        cmd = generate_command_default_model(argv)
    elif args.command == "create_roi":
        cmd = generate_command_create_roi(argv)
    elif args.command == "smooth":
        cmd = generate_command_smooth(argv)
    elif args.command == "preprocess":
        cmd = generate_command_preprocess(argv)
    elif args.command == "stats":
        cmd = generate_command_stats(argv)
    elif args.command == "contrasts":
        cmd = generate_command_contrasts(argv)
    elif args.command == "results":
        cmd = generate_command_results(argv)
    elif args.command == "bms":
        cmd = generate_command_bms(argv)

    if isinstance(cmd, int):
        raise SystemExit(cmd)

    cmd = f" bidspm('init'); try; {cmd} catch;  exit; end;"

    return_code = _run_command(cmd)

    if return_code == 1:
        raise SystemExit(EXIT_CODES["FAILURE"]["Value"])
    else:
        sys.exit(EXIT_CODES["SUCCESS"]["Value"])


def _run_command(cmd: str, platform: str | None = None) -> int:
    print("\nRunning the following command:\n")
    print(cmd.replace(";", ";\n"))
    print()

    # TODO exit matlab / octave on crash

    if platform is None:
        if Path(matlab()).exists():
            platform = matlab()
            cmd = cmd.replace(new_line, ", ")
        else:
            platform = "octave"

    if platform == "octave":
        completed_process = subprocess.run(
            [
                "octave",
                "--no-gui",
                "--no-window-system",
                "--silent",
                "--eval",
                f"{cmd}",
            ]
        )

    else:
        completed_process = subprocess.run(
            [
                platform,
                "-nodisplay",
                "-nosplash",
                "-nodesktop",
                "-r",
                f"{cmd}",
            ]
        )

    return completed_process.returncode


def _validate_actions(action: str) -> None:
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


def _validate_bids_dir(args: Any) -> None:
    bids_dir = Path(args.bids_dir[0]).absolute()
    if not bids_dir.is_dir():
        log.error("The 'bids_dir' does not exist:\n\t" f"{bids_dir}")
        raise SystemExit(EXIT_CODES["NOINPUT"]["Value"])


def _validate_space(args: Any) -> None:
    if args.command in {"stats", "contrasts", "results", "default_model", "bms"} and (
        args.space and len(args.space) > 1
    ):
        log.error(
            "Only one space allowed for statistical analysis.\n" f"Got: {args.space}"
        )
        raise SystemExit(EXIT_CODES["USAGE"]["Value"])


def _validate_analysis_level(args: Any) -> None:
    if args.command in {"smooth", "preprocess"} and args.analysis_level[0] != "subject":
        log.error(
            f"'analysis_level' can only be 'subject' for {args.command}.\n"
            f"Got: {args.analysis_level[0]}"
        )
        raise SystemExit(EXIT_CODES["USAGE"]["Value"])


def _validate_task(args: Any) -> None:
    if args.command in {"preprocess"} and args.task and len(args.task) > 1:
        log.error("Only one task allowed for preprocessing.\n" f"Got: {args.task}")
        raise SystemExit(EXIT_CODES["USAGE"]["Value"])
