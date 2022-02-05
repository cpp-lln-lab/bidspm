#!/usr/bin/env python3
import json
import os
import subprocess
from os.path import abspath
from os.path import dirname
from os.path import join
from os.path import realpath

import click
from rich import print

from bidsmreye.bidsutils import check_layout
from bidsmreye.bidsutils import get_bids_filter_config
from bidsmreye.bidsutils import get_dataset_layout
from bidsmreye.bidsutils import init_derivatives_layout

__version__ = open(join(dirname(realpath(__file__)), "version")).read()


def run(command, env={}):
    merged_env = os.environ
    merged_env.update(env)
    process = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        shell=True,
        env=merged_env,
    )
    while True:
        line = process.stdout.readline()
        line = str(line, "utf-8")[:-1]
        print(line)
        if line == "" and process.poll() != None:
            break
    if process.returncode != 0:
        raise Exception("Non zero return code: %d" % process.returncode)


@click.command()
@click.option(
    "--input-datasets",
    help="""
            The directory with the input dataset formatted according to the BIDS standard.
            """,
    type=click.Path(exists=True, dir_okay=True),
    required=True,
)
@click.option(
    "--output-location",
    help="""
            The directory where the output files should be stored.
            If you are running group level analysis this folder should be prepopulated
            with the results of the participant level analysis.
            """,
    type=click.Path(exists=False, dir_okay=True),
    required=True,
)
@click.option(
    "--analysis-level",
    help="""
            Level of the analysis that will be performed.
            Multiple participant level analyses can be run independently
            (in parallel) using the same output-location.
            """,
    default="subject",
    type=click.Choice(["subject", "group"], case_sensitive=True),
    required=True,
)
@click.option(
    "--participant-label",
    help="""
            The label(s) of the participant(s) that should be analyzed. The label
            corresponds to sub-<participant_label> from the BIDS spec
            (so it does not include "sub-"). If this parameter is not
            provided all subjects should be analyzed. Multiple
            participants can be specified with a space separated list.
            """,  # nargs ?
    required=True,
)
# TODO: implement having a list of participants
# https://stackoverflow.com/questions/48391777/nargs-equivalent-for-options-in-click
@click.option(
    "--action",
    help="""
            What to do
            """,
    type=click.Choice(["prepare", "combine", "generalize", "confounds"], case_sensitive=False),
    required=True,
)
@click.option(
    "--bids-filter-file",
    help="""
            Path to a JSON file to filter input file
            """,
    default="",
    show_default=True,
)
@click.option(
    "--dry-run",
    help="""

            """,
    default=False,
    show_default=True,
)
def main(
    input_datasets,
    output_location,
    analysis_level,
    participant_label,
    action,
    bids_filter_file,
    dry_run,
):

    input_datasets = abspath(input_datasets)
    print(f"Input dataset: {input_datasets}")

    output_location = abspath(output_location)
    print(f"Output location: {output_location}")

    if bids_filter_file == "":
        bids_filter = get_bids_filter_config()
    else:
        bids_filter = get_bids_filter_config(bids_filter_file)

    if action == "prepare":

        layout_in = get_dataset_layout(input_datasets)
        check_layout(layout_in)

        layout_out = init_derivatives_layout(output_location)

        # print(layout.get_subjects())

        # print(layout.get_sessions())

        # TODO add loop for subjects

        skullstrip(layout_in, layout_out, participant_label, bids_filter=bids_filter)

    elif action == "combine":

        layout_out = get_dataset_layout(output_location)

        segment(layout_out, participant_label, bids_filter=bids_filter, dry_run=dry_run)

# parser.add_argument('-v', '--version', action='version',
#                     version='bidsNighRes {}'.format(__version__))

if __name__ == "__main__":
    main()
