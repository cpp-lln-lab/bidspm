#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import sys
from pathlib import Path
from typing import Any

from rich import print

from .matlab import matlab
from .parsers import bidspm_log, common_parser

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
    options: Path | None = None,
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
    if options:
        cmd += f"{new_line}'options', '{str(options)}'"

    return cmd


def append_common_arguments(
    cmd: str,
    skip_validation: bool = False,
    dry_run: bool = False,
    fwhm: Any = 6,
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
    options: Path | None = None,
) -> int | str:
    if space and len(space) > 1:
        log.error(f"Only one space allowed for statistical analysis. Got\n:{space}")
        return 1

    cmd = generate_cmd(
        bids_dir=bids_dir,
        output_dir=output_dir,
        analysis_level=analysis_level,
        action="default_model",
        verbosity=verbosity,
        space=space,
        task=task,
        ignore=ignore,
        options=options,
    )
    cmd = end_cmd(cmd)

    log.info("Creating default model.")

    return cmd


def preprocess(
    bids_dir: Path,
    output_dir: Path,
    action: str,
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
    options: Path | None = None,
) -> int | str:
    if action == "preprocess" and task and len(task) > 1:
        log.error(f"Only one task allowed for preprocessing. Got\n:{task}")
        return 1

    cmd = generate_cmd(
        bids_dir=bids_dir,
        output_dir=output_dir,
        analysis_level="subject",
        action=action,
        verbosity=verbosity,
        space=space,
        task=task,
        ignore=ignore,
        options=options,
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

    if action == "preprocess":
        log.info("Running preprocessing.")
        log.info("For typical fmri data, consider using fmriprep instead.")

    elif action == "smooth":
        log.info("Running smoothing.")

    return cmd


def create_roi(
    bids_dir: Path,
    output_dir: Path,
    preproc_dir: Path | None = None,
    verbosity: int = 2,
    participant_label: list[str] | None = None,
    roi_dir: Path | None = None,
    roi_atlas: str | None = "neuromorphometrics",
    roi_name: list[str] | None = None,
    space: list[str] | None = None,
    bids_filter_file: Path | None = None,
    options: Path | None = None,
) -> str:
    roi_name = "{ '" + "', '".join(roi_name) + "' }" if roi_name is not None else None  # type: ignore
    if roi_dir is None:
        roi_dir = Path()

    cmd = generate_cmd(
        bids_dir=bids_dir,
        output_dir=output_dir,
        analysis_level="subject",
        action="create_roi",
        verbosity=verbosity,
        space=space,
        options=options,
    )
    cmd = append_common_arguments(
        cmd=cmd,
        participant_label=participant_label,
        bids_filter_file=bids_filter_file,
    )
    cmd += f"{new_line}'roi_atlas', '{roi_atlas}'"
    cmd += f"{new_line}'roi_name', {roi_name}"
    if roi_dir:
        cmd += f"{new_line}'roi_dir', '{roi_dir}'"
    if preproc_dir:
        cmd += f"{new_line}'preproc_dir', '{preproc_dir}'"
    cmd = end_cmd(cmd)

    log.info("Creating ROI.")

    return cmd


def stats(
    bids_dir: Path,
    output_dir: Path,
    analysis_level: str,
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
    keep_residuals: bool = False,
    options: Path | None = None,
) -> int | str:
    if space and len(space) > 1:
        log.error(f"Only one space allowed for statistical analysis. Got\n:{space}")
        return 1

    cmd = generate_cmd(
        bids_dir=bids_dir,
        output_dir=output_dir,
        analysis_level=analysis_level,
        action=action,
        verbosity=verbosity,
        space=space,
        task=task,
        ignore=ignore,
        options=options,
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
    if keep_residuals:
        cmd += f"{new_line}'keep_residuals', true"
    cmd = end_cmd(cmd)

    log.info("Running statistics.")

    return cmd


def generate_cmd(
    bids_dir: Path,
    output_dir: Path,
    analysis_level: str,
    action: str,
    verbosity: int = 2,
    space: list[str] | None = None,
    task: list[str] | None = None,
    ignore: list[str] | None = None,
    options: Path | None = None,
) -> str:
    cmd = base_cmd(bids_dir=bids_dir, output_dir=output_dir)
    cmd = append_main_cmd(cmd=cmd, analysis_level=analysis_level, action=action)
    cmd = append_base_arguments(
        cmd=cmd,
        verbosity=verbosity,
        space=space,
        task=task,
        ignore=ignore,
        options=options,
    )
    return cmd


def cli(argv: Any = sys.argv) -> None:
    parser = common_parser()

    args, _ = parser.parse_known_args(argv[1:])

    bids_dir = Path(args.bids_dir[0]).resolve()
    output_dir = Path(args.output_dir[0]).resolve()
    analysis_level = args.analysis_level[0]
    action = args.action[0]
    roi_atlas = args.roi_atlas[0]
    bids_filter_file = (
        Path(args.bids_filter_file[0]).resolve()
        if args.bids_filter_file is not None
        else None
    )
    preproc_dir = (
        Path(args.preproc_dir[0]).absolute() if args.preproc_dir is not None else None
    )
    model_file = (
        Path(args.model_file[0]).absolute() if args.model_file is not None else None
    )
    options = Path(args.options[0]).absolute() if args.options is not None else None

    return_code = bidspm(
        bids_dir,
        output_dir,
        analysis_level,
        action=action,
        participant_label=args.participant_label,
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
        roi_atlas=roi_atlas,
        roi_name=args.roi_name,
        roi_dir=args.roi_dir,
        concatenate=args.concatenate,
        design_only=args.design_only,
        keep_residuals=args.keep_residuals,
        options=options,
    )

    if return_code == 1:
        sys.exit(1)
    else:
        sys.exit(0)


def bidspm(
    bids_dir: Path,
    output_dir: Path,
    analysis_level: str,
    action: str,
    participant_label: list[str] | None = None,
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
    roi_atlas: str | None = None,
    roi_name: list[str] | None = None,
    roi_dir: Path | None = None,
    concatenate: bool = False,
    design_only: bool = False,
    keep_residuals: bool = False,
    options: Path | None = None,
) -> int:
    if not bids_dir.is_dir():
        log.error(f"The 'bids_dir' does not exist:\n\t{bids_dir}")
        return 1

    if preproc_dir is not None and not preproc_dir.is_dir():
        log.error(f"The 'preproc_dir' does not exist:\n\t{preproc_dir}")
        return 1

    if action == "default_model":
        cmd = default_model(
            bids_dir=bids_dir,
            output_dir=output_dir,
            analysis_level=analysis_level,
            verbosity=verbosity,
            task=task,
            space=space,
            ignore=ignore,
            options=options,
        )

    elif action in {"preprocess", "smooth"}:
        cmd = preprocess(
            bids_dir=bids_dir,
            output_dir=output_dir,
            action=action,
            participant_label=participant_label,
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
            options=options,
        )
    elif action in {"create_roi"}:
        cmd = create_roi(
            bids_dir=bids_dir,
            output_dir=output_dir,
            preproc_dir=preproc_dir,
            verbosity=verbosity,
            participant_label=participant_label,
            roi_dir=roi_dir,
            roi_atlas=roi_atlas,
            roi_name=roi_name,
            space=space,
            bids_filter_file=bids_filter_file,
            options=options,
        )

    elif action in {"stats", "contrasts", "results"}:
        if preproc_dir is None or not preproc_dir.exists():
            log.error(f"'preproc_dir' must be specified for stats. Got:\n{preproc_dir}")
            return 1

        if model_file is None or not model_file.exists():
            log.error(f"'model_file' must be specified for stats. Got:\n{model_file}")
            return 1

        cmd = stats(
            bids_dir=bids_dir,
            output_dir=output_dir,
            analysis_level=analysis_level,
            action=action,
            preproc_dir=preproc_dir,
            model_file=model_file,
            verbosity=verbosity,
            participant_label=participant_label,
            space=space,
            ignore=ignore,
            fwhm=fwhm,
            skip_validation=skip_validation,
            bids_filter_file=bids_filter_file,
            dry_run=dry_run,
            roi_based=roi_based,
            concatenate=concatenate,
            design_only=design_only,
            keep_residuals=keep_residuals,
            options=options,
        )
    else:
        log.error(f"\nunknown action: {action}")
        return 1

    return cmd if isinstance(cmd, int) else run_command(cmd)


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
