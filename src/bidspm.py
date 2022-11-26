#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import sys
from pathlib import Path
from typing import Any

from rich import print

from src.matlab import matlab
from src.parsers import bidspm_log
from src.parsers import common_parser

log = bidspm_log(name="bidspm")

new_line = ", ...\n\t\t\t "


def base_cmd(bids_dir: Path, output_dir: Path) -> str:
    cmd = " bidspm();"
    cmd += f" bidspm('{bids_dir}'{new_line}'{output_dir}'"
    return cmd


def append_main_cmd(cmd: str, analysis_level: str, action: str) -> str:
    cmd += f"{new_line}'{analysis_level}'{new_line}'action', '{action}'"
    return cmd


def end_cmd(cmd: str) -> str:
    cmd += "); exit;"
    return cmd


def append_base_arguments(
    cmd: str,
    verbosity: int | None = None,
    space: list[str] | None = None,
    task: list[str] | None = None,
    ignore: list[str] | None = None,
) -> str:
    """Append arguments common to all actions to the command string."""
    task = "{ '" + "', '".join(task) + "' }" if task is not None else None  # type: ignore
    space = "{ '" + "', '".join(space) + "' }" if space is not None else None  # type: ignore
    ignore = "{ '" + "', '".join(ignore) + "' }" if ignore is not None else None  # type: ignore

    if verbosity is not None:
        cmd += f"{new_line}'verbosity', {verbosity}"
    if space:
        cmd += f"{new_line}'space', {space}"
    if task:
        cmd += f"{new_line}'task', {task}"
    if ignore:
        cmd += f"{new_line}'ignore', {ignore}"

    return cmd


def append_common_arguments(
    cmd: str,
    fwhm: Any,
    skip_validation: bool,
    dry_run: bool,
    participant_label: list[str] | None = None,
    bids_filter_file: Path | None = None,
) -> str:
    """Append arguments common to preproc and stats."""
    participant_label = (
        "{ '" + "', '".join(participant_label) + "' }"  # type: ignore
        if participant_label is not None
        else None
    )

    cmd += f"{new_line}'fwhm', {fwhm}"
    if participant_label:
        cmd += f"{new_line}'participant_label', {participant_label}"
    if skip_validation:
        cmd += f"{new_line}'skip_validation', true"
    if dry_run:
        cmd += f"{new_line}'dry_run', true"
    if bids_filter_file:
        cmd += f"{new_line}'bids_filter_file', '{bids_filter_file}'"

    return cmd


def default_model(
    bids_dir: Path,
    output_dir: Path,
    analysis_level: str = "dataset",
    verbosity: int = 2,
    space: list[str] | None = None,
    task: list[str] | None = None,
    ignore: list[str] | None = None,
) -> int:

    if space and len(space) > 1:
        log.error(f"Only one space allowed for statistical analysis. Got\n:{space}")
        return 1

    cmd = base_cmd(bids_dir=bids_dir, output_dir=output_dir)
    cmd = append_main_cmd(cmd=cmd, analysis_level=analysis_level, action="default_model")
    cmd = append_base_arguments(
        cmd=cmd, verbosity=verbosity, space=space, task=task, ignore=ignore
    )
    cmd = end_cmd(cmd)

    log.info("Creating default model.")

    run_command(cmd)

    return 0


def preprocess(
    bids_dir: Path,
    output_dir: Path,
    verbosity: int = 2,
    participant_label: list[str] | None = None,
    fwhm: Any = 6,
    dummy_scans: int | None = None,
    space: list[str] | None = None,
    task: list[str] | None = None,
    ignore: list[str] | None = None,
    anat_only: bool = False,
    skip_validation: bool = False,
    bids_filter_file: Path | None = None,
    dry_run: bool = False,
) -> int:

    if task and len(task) > 1:
        log.error(f"Only one task allowed for preprocessing. Got\n:{task}")
        return 1

    cmd = base_cmd(bids_dir=bids_dir, output_dir=output_dir)
    cmd = append_main_cmd(cmd=cmd, analysis_level="subject", action="preprocess")
    cmd = append_base_arguments(
        cmd=cmd, verbosity=verbosity, space=space, task=task, ignore=ignore
    )
    cmd = append_common_arguments(
        cmd=cmd,
        fwhm=fwhm,
        participant_label=participant_label,
        skip_validation=skip_validation,
        dry_run=dry_run,
        bids_filter_file=bids_filter_file,
    )
    if anat_only:
        cmd += f"{new_line}'anat_only', true"
    if dummy_scans:
        cmd += f"{new_line}'dummy_scans', {dummy_scans}"
    cmd = end_cmd(cmd)

    log.info("Running preprocessing.")
    log.info("For typical fmri data, consider using fmriprep instead.")

    run_command(cmd)

    return 0


def stats(
    bids_dir: Path,
    output_dir: Path,
    action: str,
    preproc_dir: Path,
    model_file: Path,
    verbosity: int = 2,
    participant_label: list[str] | None = None,
    fwhm: Any = 6,
    space: list[str] | None = None,
    task: list[str] | None = None,
    ignore: list[str] | None = None,
    skip_validation: bool = False,
    bids_filter_file: Path | None = None,
    dry_run: bool = False,
    roi_based: bool = False,
    concatenate: bool = False,
    design_only: bool = False,
) -> int:

    if space and len(space) > 1:
        log.error(f"Only one space allowed for statistical analysis. Got\n:{space}")
        return 1

    cmd = base_cmd(bids_dir=bids_dir, output_dir=output_dir)
    cmd = append_main_cmd(cmd=cmd, analysis_level="subject", action=action)
    cmd = append_base_arguments(
        cmd=cmd, verbosity=verbosity, space=space, task=task, ignore=ignore
    )
    cmd = append_common_arguments(
        cmd=cmd,
        fwhm=fwhm,
        participant_label=participant_label,
        skip_validation=skip_validation,
        dry_run=dry_run,
        bids_filter_file=bids_filter_file,
    )
    cmd += f"{new_line}'preproc_dir', '{preproc_dir}'"
    cmd += f"{new_line}'model_file', '{model_file}'"
    if roi_based:
        cmd += f"{new_line}'roi_based', true"
    if concatenate:
        cmd += f"{new_line}'concatenate', true"
    if design_only:
        cmd += f"{new_line}'design_only', true"
    cmd = end_cmd(cmd)

    log.info("Running statistics.")

    run_command(cmd)

    return 0


def cli(argv: Any = sys.argv) -> None:

    parser = common_parser()

    args, unknowns = parser.parse_known_args(argv[1:])

    bids_dir = Path(args.bids_dir[0]).resolve()
    output_dir = Path(args.output_dir[0]).resolve()
    analysis_level = args.analysis_level[0]
    action = args.action[0]
    bids_filter_file = (
        Path(args.bids_filter_file[0]).resolve()
        if args.bids_filter_file is not None
        else None
    )
    preproc_dir = (
        Path(args.preproc_dir[0]).resolve() if args.preproc_dir is not None else None
    )
    model_file = (
        Path(args.model_file[0]).resolve() if args.model_file is not None else None
    )

    sts = bidspm(
        bids_dir,
        output_dir,
        analysis_level,
        action=action,
        verbosity=args.verbosity,
        task=args.task,
        space=args.space,
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
        concatenate=args.concatenate,
        design_only=args.design_only,
    )

    if sts == 1:
        sys.exit(1)
    else:
        sys.exit(0)


def bidspm(
    bids_dir: Path,
    output_dir: Path,
    analysis_level: str,
    action: str,
    verbosity: int = 2,
    task: list[str] | None = None,
    space: list[str] | None = None,
    ignore: list[str] | None = None,
    fwhm: Any = None,
    bids_filter_file: Path | None = None,
    dummy_scans: int | None = 0,
    anat_only: bool = False,
    skip_validation: bool = False,
    dry_run: bool = False,
    preproc_dir: Path | None = None,
    model_file: Path | None = None,
    roi_based: bool = False,
    concatenate: bool = False,
    design_only: bool = False,
) -> int:

    if not bids_dir.is_dir():
        log.error(f"The 'bids_dir' does not exist:\n\t{bids_dir}")
        return 1

    if preproc_dir is not None and not preproc_dir.is_dir():
        log.error(f"The 'preproc_dir' does not exist:\n\t{preproc_dir}")
        return 1

    if action == "default_model":
        sts = default_model(
            bids_dir=bids_dir,
            output_dir=output_dir,
            analysis_level=analysis_level,
            verbosity=verbosity,
            task=task,
            space=space,
            ignore=ignore,
        )

    elif action == "preprocess":
        sts = preprocess(
            bids_dir=bids_dir,
            output_dir=output_dir,
            verbosity=verbosity,
            task=task,
            space=space,
            ignore=ignore,
            fwhm=fwhm,
            dummy_scans=dummy_scans,
            skip_validation=skip_validation,
            anat_only=anat_only,
            bids_filter_file=bids_filter_file,
            dry_run=dry_run,
        )
    elif action in {"stats", "contrasts", "results"}:

        if preproc_dir is None or not preproc_dir.exists():
            log.error(f"'preproc_dir' must be specified for stats. Got:\n{preproc_dir}")
            return 1

        if model_file is None or not model_file.exists():
            log.error(f"'model_file' must be specified for stats. Got:\n{model_file}")
            return 1

        sts = stats(
            bids_dir=bids_dir,
            output_dir=output_dir,
            action=action,
            preproc_dir=preproc_dir,
            model_file=model_file,
            verbosity=verbosity,
            task=task,
            space=space,
            ignore=ignore,
            fwhm=fwhm,
            skip_validation=skip_validation,
            bids_filter_file=bids_filter_file,
            dry_run=dry_run,
            roi_based=roi_based,
            concatenate=concatenate,
            design_only=design_only,
        )
    else:
        log.error(f"\nunknown action: {action}")
        return 1

    return sts


def run_command(cmd: str, platform: str | None = None) -> int:

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
