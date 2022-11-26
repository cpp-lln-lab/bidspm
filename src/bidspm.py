#!/usr/bin/env python3
import os
import subprocess
import sys
from pathlib import Path
from typing import Any
from typing import Optional

from rich import print

from src.matlab import matlab
from src.parsers import bidspm_log
from src.parsers import common_parser
from src.utils import root_dir

log = bidspm_log(name="bidspm")

new_line = ", ...\n\t "


def default_model(
    bids_dir: Path,
    output_dir: Path,
    analysis_level: str = "dataset",
    verbosity: int = 2,
    space: Optional[list[str]] = None,
    task: Optional[list[str]] = None,
    ignore: Optional[list[str]] = None,
) -> None:

    if space and len(space) > 1:
        log.error(f"Only one space allowed for statistical analysis. Got\n:{space}")
        sys.exit(1)

    cmd = base_cmd(bids_dir, output_dir)
    cmd += f"{new_line}'dataset'{new_line}'action', 'default_model'"
    cmd = append_base_arguments(cmd, verbosity, space, task, ignore)
    cmd += "); exit;"

    log.info("Creating default model.")

    run_command(cmd)


def base_cmd(bids_dir: Path, output_dir: Path) -> str:
    cmd = " bidspm();"
    cmd += f" bidspm('{bids_dir}'{new_line}'{output_dir}'"
    return cmd


def append_base_arguments(
    cmd: str,
    verbosity: int,
    space: Optional[list[str]],
    task: Optional[list[str]],
    ignore: Optional[list[str]],
) -> str:
    """Append arguments common to all actions to the command string."""
    task = "{ '" + "', '".join(task) + "' }" if task is not None else None
    space = "{ '" + "', '".join(space) + "' }" if space is not None else None
    ignore = "{ '" + "', '".join(ignore) + "' }" if ignore is not None else None

    if verbosity:
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
    participant_label: Optional[list[str]],
    skip_validation: bool,
    dry_run: bool,
    bids_filter_file: Optional[Path],
) -> str:
    """Append arguments common to preproc and stats."""
    participant_label = (
        "{ '" + "', '".join(participant_label) + "' }"
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


def preprocess(
    bids_dir: Path,
    output_dir: Path,
    verbosity: int = 2,
    participant_label: Optional[list[str]] = None,
    fwhm: Any = 6,
    dummy_scans: Optional[int] = None,
    space: Optional[list[str]] = None,
    task: Optional[list[str]] = None,
    ignore: Optional[list[str]] = None,
    anat_only: bool = False,
    skip_validation: bool = False,
    bids_filter_file: Optional[Path] = None,
    dry_run: bool = False,
) -> None:

    if task and len(task) > 1:
        log.error(f"Only one task allowed for preprocessing. Got\n:{task}")
        sys.exit(1)

    cmd = base_cmd(bids_dir, output_dir)
    cmd += f"{new_line}'subject'{new_line}'action', 'preprocess'"
    cmd = append_base_arguments(cmd, verbosity, space, task, ignore)
    cmd = append_common_arguments(
        cmd, fwhm, participant_label, skip_validation, dry_run, bids_filter_file
    )
    if anat_only:
        cmd += f"{new_line}'anat_only', true"
    if dummy_scans:
        cmd += f"{new_line}'dummy_scans', {dummy_scans}"
    cmd += "); exit();"

    log.info("Running preprocessing. Consider using fmriprep for regular data.")

    run_command(cmd)


def stats(
    bids_dir: Path,
    output_dir: Path,
    action: str,
    preproc_dir: Path,
    model_file: Path,
    verbosity: int = 2,
    participant_label: Optional[list[str]] = None,
    fwhm: Any = 6,
    space: Optional[list[str]] = None,
    task: Optional[list[str]] = None,
    ignore: Optional[list[str]] = None,
    skip_validation: bool = False,
    bids_filter_file: Optional[Path] = None,
    dry_run: bool = False,
    roi_based: bool = False,
    concatenate: bool = False,
    design_only: bool = False,
) -> None:

    if space and len(space) > 1:
        log.error(f"Only one space allowed for statistical analysis. Got\n:{space}")
        sys.exit(1)

    cmd = base_cmd(bids_dir, output_dir)
    cmd += f"'{new_line}'subject'{new_line}'action', '{action}'"
    cmd = append_base_arguments(cmd, verbosity, space, task, ignore)
    cmd = append_common_arguments(
        cmd, fwhm, participant_label, skip_validation, dry_run, bids_filter_file
    )
    cmd += f"{new_line}'preproc_dir', '{preproc_dir}'"
    cmd += f"{new_line}'model_file', '{model_file}'"
    if roi_based:
        cmd += f"{new_line}'roi_based', true"
    if concatenate:
        cmd += f"{new_line}'concatenate', true"
    if design_only:
        cmd += f"{new_line}'design_only', true"
    cmd += "); exit();"

    log.info("Running statistics.")

    run_command(cmd)


def cli(argv: Any = sys.argv) -> None:

    parser = common_parser()

    args, unknowns = parser.parse_known_args(argv[1:])

    os.chdir(root_dir())

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

    bidspm(
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


def bidspm(
    bids_dir: Path,
    output_dir: Path,
    analysis_level: str,
    action: str,
    verbosity: int = 2,
    task: Optional[list[str]] = None,
    space: Optional[list[str]] = None,
    ignore: Optional[list[str]] = None,
    fwhm: Any = None,
    bids_filter_file: Optional[Path] = None,
    dummy_scans: Optional[int] = 0,
    anat_only: bool = False,
    skip_validation: bool = False,
    dry_run: bool = False,
    preproc_dir: Optional[Path] = None,
    model_file: Optional[Path] = None,
    roi_based: bool = False,
    concatenate: bool = False,
    design_only: bool = False,
) -> None:

    if action == "default_model":
        default_model(
            bids_dir=bids_dir,
            output_dir=output_dir,
            analysis_level=analysis_level,
            verbosity=verbosity,
            task=task,
            space=space,
            ignore=ignore,
        )

    elif action == "preprocess":
        preprocess(
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
            sys.exit(1)

        if model_file is None or not model_file.exists():
            log.error(f"'model_file' must be specified for stats. Got:\n{model_file}")
            sys.exit(1)

        stats(
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
        print(f"\nunknown action: {action}")


def run_command(cmd: str) -> None:

    print("\nRunning the following command:\n")
    print(cmd.replace(";", ";\n"))
    print()

    platform = "octave"
    if Path(matlab()).exists():
        platform = matlab()
        cmd = cmd.replace(new_line, ", ")

    if platform == "octave":
        subprocess.run(
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
        subprocess.run(
            [
                platform,
                "-nodisplay",
                "-nosplash",
                "-nodesktop",
                "-r",
                f"{cmd}",
            ]
        )
