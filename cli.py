#!/usr/bin/env python3
import argparse
import os
import subprocess

__version__ = open(
    os.path.join(os.path.dirname(os.path.realpath(__file__)), "version.txt")
).read()


def run(command, env=None):  # sourcery skip: raise-specific-error
    if env is None:
        env = {}
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


parser = argparse.ArgumentParser(description="Example BIDS App entrypoint script.")
parser.add_argument(
    "bids_dir",
    help="The directory with the input dataset "
    "formatted according to the BIDS standard.",
)
parser.add_argument(
    "output_dir",
    help="The directory where the output files "
    "should be stored. If you are running group level analysis "
    "this folder should be prepopulated with the results of the"
    "participant level analysis.",
)
parser.add_argument(
    "analysis_level",
    help="Level of the analysis that will be performed. "
    "Multiple participant level analyses can be run independently "
    "(in parallel) using the same output_dir.",
    choices=["participant", "group"],
)
parser.add_argument(
    "--participant_label",
    help="The label(s) of the participant(s) that should be analyzed. The label "
    "corresponds to sub-<participant_label> from the BIDS spec "
    '(so it does not include "sub-"). If this parameter is not '
    "provided all subjects should be analyzed. Multiple "
    "participants can be specified with a space separated list.",
    nargs="+",
)
parser.add_argument(
    "--skip_bids_validator",
    help="Whether or not to perform BIDS dataset validation",
    action="store_true",
)
parser.add_argument(
    "-v",
    "--version",
    action="version",
    version=f"BIDS-App example version {__version__}",
)


args = parser.parse_args()

if not args.skip_bids_validator:
    run(f"bids-validator {args.bids_dir}")

subjects_to_analyze = args.participant_label or []
