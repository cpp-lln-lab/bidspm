#!/usr/bin/env python3
import os
import subprocess
import sys
from pathlib import Path

from rich import print

from src.parsers import common_parser
from src.utils import root_dir


def default_model(
    bids_dir,
    output_dir,
    analysis_level="dataset",
    verbosity=2,
    space=None,
    task=None,
    ignore=None,
) -> None:

    task = "{ '" + "', '".join(task) + "' }" if task is not None else None
    # TODO check only one space
    space = "{ '" + "', '".join(space) + "' }" if space is not None else None
    ignore = "{ '" + "', '".join(ignore) + "' }" if ignore is not None else None

    new_line = ", ...\n\t "
    octave_cmd = " bidspm();"
    octave_cmd += f" bidspm('{bids_dir}'{new_line}'{output_dir}'{new_line}'dataset'{new_line}'action', 'default_model'"
    if verbosity:
        octave_cmd += f"{new_line}'verbosity', {verbosity}"
    if space:
        octave_cmd += f"{new_line}'space', {space}"
    if task:
        octave_cmd += f"{new_line}'task', {task}"
    if ignore:
        octave_cmd += f"{new_line}'ignore', {ignore}"

    octave_cmd += "); exit;"

    print("\nRunning the following command:\n")
    print(octave_cmd.replace(";", ";\n"))
    print()

    subprocess.run(
        [
            "octave",
            "--no-gui",
            "--no-window-system",
            "--silent",
            "--eval",
            f"{octave_cmd}",
        ]
    )


def preprocess(
    bids_dir,
    output_dir,
    verbosity=2,
    participant_label=None,
    fwhm=6,
    space=None,
    task=None,
    ignore=None,
    anat_only=False,
    skip_validation=False,
) -> None:

    task = "{ '" + "', '".join(task) + "' }" if task is not None else None
    space = "{ '" + "', '".join(space) + "' }" if space is not None else None
    ignore = "{ '" + "', '".join(ignore) + "' }" if ignore is not None else None
    participant_label = (
        "{ '" + "', '".join(participant_label) + "' }"
        if participant_label is not None
        else None
    )

    new_line = ", ...\n\t "
    octave_cmd = " bidspm();"
    octave_cmd += f" bidspm('{bids_dir}'{new_line}'{output_dir}'{new_line}'subject'{new_line}'action', 'preprocess'"
    octave_cmd += f"{new_line}'fwhm', {fwhm}"
    if verbosity:
        octave_cmd += f"{new_line}'verbosity', {verbosity}"
    if space:
        octave_cmd += f"{new_line}'space', {space}"
    if task:
        octave_cmd += f"{new_line}'task', {task}"
    if participant_label:
        octave_cmd += f"{new_line}'participant_label', {participant_label}"
    if ignore:
        octave_cmd += f"{new_line}'ignore', {ignore}"
    if skip_validation:
        octave_cmd += f"{new_line}'skip_validation', true"
    if anat_only:
        octave_cmd += f"{new_line}'anat_only', true"

    octave_cmd += "); exit();"

    print("\nRunning the following command:\n")
    print(octave_cmd.replace(";", ";\n"))
    print()

    subprocess.run(
        [
            "octave",
            "--no-gui",
            "--no-window-system",
            "--silent",
            "--eval",
            f"{octave_cmd}",
        ]
    )


def cli(argv=sys.argv) -> None:

    parser = common_parser()

    args, unknowns = parser.parse_known_args(argv[1:])

    os.chdir(root_dir())

    bids_dir = Path(args.bids_dir[0]).resolve()
    output_dir = Path(args.output_dir[0]).resolve()
    analysis_level = args.analysis_level[0]
    action = args.action[0]
    task = args.task
    space = args.space
    verbosity = args.verbosity
    ignore = args.ignore
    fwhm = args.fwhm
    bids_filter_file = args.bids_filter_file
    dummy_scans = args.dummy_scans
    anat_only = args.anat_only
    skip_validation = args.skip_validation

    bidspm(
        bids_dir,
        output_dir,
        analysis_level,
        action=action,
        verbosity=verbosity,
        task=task,
        space=space,
        ignore=ignore,
        fwhm=fwhm,
        bids_filter_file=bids_filter_file,
        dummy_scans=dummy_scans,
        anat_only=anat_only,
        skip_validation=skip_validation,
    )


def bidspm(
    bids_dir,
    output_dir,
    analysis_level,
    action=None,
    verbosity=2,
    task=None,
    space=None,
    ignore=None,
    fwhm=None,
    bids_filter_file=None,
    dummy_scans=0,
    anat_only=False,
    skip_validation=False,
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
            skip_validation=skip_validation,
            anat_only=anat_only,
        )
    else:
        print(f"\nunknown action: {action}")
