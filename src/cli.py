#!/usr/bin/env python3
import argparse
import sys

# from . import _version

# __version__ = _version.get_versions()["version"]
__version__ = 2


def main(argv=sys.argv) -> None:

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


if __name__ == "__main__":
    main()
