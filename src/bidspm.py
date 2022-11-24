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

    octave_cmd = " bidspm();"
    octave_cmd += (
        f" bidspm('{bids_dir}', '{output_dir}', 'dataset', 'action', 'default_model'"
    )
    if verbosity:
        octave_cmd += f", 'verbosity', {verbosity}"
    if space:
        octave_cmd += f", 'space', {space}"
    if task:
        octave_cmd += f", 'task', {task}"
    if ignore:
        octave_cmd += f", 'ignore', {ignore}"

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
) -> None:

    task = "{ '" + "', '".join(task) + "' }" if task is not None else None
    space = "{ '" + "', '".join(space) + "' }" if space is not None else None
    ignore = "{ '" + "', '".join(ignore) + "' }" if ignore is not None else None
    participant_label = (
        "{ '" + "', '".join(participant_label) + "' }"
        if participant_label is not None
        else None
    )

    octave_cmd = " bidspm();"
    octave_cmd += (
        f" bidspm('{bids_dir}', '{output_dir}', 'subject', 'action', 'preprocess'"
    )
    octave_cmd += f", 'fwhm', {fwhm}"
    if verbosity:
        octave_cmd += f", 'verbosity', {verbosity}"
    if space:
        octave_cmd += f", 'space', {space}"
    if task:
        octave_cmd += f", 'task', {task}"
    if participant_label:
        octave_cmd += f", 'participant_label', {participant_label}"
    if ignore:
        octave_cmd += f", 'ignore', {ignore}"

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
    if action == "preprocess":
        preprocess(
            bids_dir=bids_dir,
            output_dir=output_dir,
            verbosity=verbosity,
            task=task,
            space=space,
            ignore=ignore,
            fwhm=fwhm,
        )
    else:
        print(f"\nunknown action: {action}")
