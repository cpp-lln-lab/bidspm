#!/usr/bin/env python3
import argparse
import sys
from typing import IO
from typing import Optional

import _version
import rich

__version__ = _version.get_versions()["version"]


def main(argv=sys.argv) -> None:

    parser = preproc_parser()

    args = parser.parse_args(argv[1:])


class MuhParser(argparse.ArgumentParser):
    def _print_message(self, message: str, file: Optional[IO[str]] = None) -> None:
        rich.print(message, file=file)


def base_parser():

    parser = MuhParser(
        description="bidspm is a SPM base BIDS app",
        epilog=f"""
        \n- all parameters use ``snake_case``,
        \n- most "invalid" calls simply initialize bidspm.

        For a more readable version of this help section,
        see the online https://cpp-spm.readthedocs.io/en/dev/bids_app_api.html.
        """,
    )

    parser.add_argument(
        "-v",
        "--version",
        action="version",
        version=f"{__version__}",
    )

    return parser


def low_level_parser():

    parser = common_parser()

    parser.add_argument(
        "--action",
        help="""
        Low level action to perform.

        - ``init``: initialise (add relevant folders to MATLAB path).
        - ``dev``: initialise and also adds folder for testing to the path.
        - ``uninit``: uninitialise (remove relevant folders from MATLAB path)
        - ``update``: tries to update the current branch from the upstream repository
        - ``run_tests``: tries to update the current branch from the upstream repository
        """,
        choices=["init", "dev", "uninit", "update", "run_tests"],
        required=True,
        type=str,
        nargs=1,
    )
    return parser


def common_parser():

    parser = base_parser()

    """
    **COMMON:**

    obligatory
    """
    parser.add_argument(
        "bids_dir",
        help="""
        The directory with the input dataset
        formatted according to the BIDS standard.
        """,
        nargs=1,
    )
    parser.add_argument(
        "output_dir",
        help="""
        The directory where the output files will be stored.
        If you are running group level analysis this folder should be prepopulated
        with the results of the participant level analysis.
        """,
        nargs=1,
    )
    parser.add_argument(
        "analysis_level",
        help="""
        Level of the analysis that will be performed.
        Multiple participant level analyses can be run independently
        (in parallel) using the same ``output_dir``.
        """,
        choices=["subject", "dataset"],
        type=str,
        nargs=1,
    )
    parser.add_argument(
        "--action",
        help="""
        Level of the analysis that will be performed.
        Multiple participant level analyses can be run independently
        (in parallel) using the same output_dir.

        \n- stats: runs model specification / estimation, contrast computation, display results
        """,
        choices=[
            "preprocess",
            "stats",
            "contrasts",
            "results",
        ],
        required=True,
        type=str,
        nargs=1,
    )
    """
    **COMMON:**

    optional
    """
    parser.add_argument(
        "--participant_label",
        help="""
        The label(s) of the participant(s) that should be analyzed.
        The label corresponds to sub-<participant_label> from the BIDS spec
        (so it does not include "sub-").
        If this parameter is not provided all subjects should be analyzed.
        Multiple participants can be specified with a space separated list.
        Can be a regular expression.
        Example: ``'01', '03', '08'``.
        """,
        nargs="+",
    )
    parser.add_argument(
        "--dry_run",
        help="""
        When set to ``true`` this will generate and save the SPM batches,
        but not actually run them.
        """,
        choices=[True, False],
        default=False,
        type=bool,
        nargs=1,
    )
    parser.add_argument(
        "--bids_filter_file",
        help="""
        A JSON file describing custom BIDS input filters.
        """,
    )
    parser.add_argument(
        "--verbosity",
        help="""
        Verbosity level.
        """,
        choices=[0, 1, 2],
        default=2,
        type=int,
        nargs=1,
    )
    parser.add_argument(
        "--space",
        help="""
        Space to normalize to generate output in for ``preprocess``
        or to use as input for ``stats``.
        Only one value is allowed for ``stats``
        """,
        default=["individual", "IXI549Space"],
        nargs="+",
    )
    parser.add_argument(
        "--options",
        help="""
        Path to JSON file containing bidspm options.
        """,
    )

    return parser


def preproc_parser():

    parser = common_parser()

    """
    **PREPROCESSING:**

    obligatory
    """
    parser.add_argument(
        "--task",
        help="""
        Tasks to ``preprocess`` or to include in ``stats``.
        Only one value allowed for ``preprocess``.
        """,
    )
    parser.add_argument(
        "--dummy_scans",
        help="""
        Number of dummy scans to remove.
        """,
        type=int,
        nargs=1,
        default=0,
    )
    """
    optional
    """
    parser.add_argument(
        "--anat_only",
        help="""
        If preprocessing should be done only on anatomocal data.
        """,
        choices=[True, False],
        default=False,
        type=bool,
        nargs=1,
    )
    parser.add_argument(
        "--ignore",
        help="""
        If preprocessing should be done only on anatomical data.
        """,
        choices=["fieldmaps", "slicetiming", "unwarp"],
        nargs="+",
    )
    parser.add_argument(
        "--fwhm",
        help="""
        The full width at half maximum of the gaussian kernel to apply to the preprocessed data.
        """,
        type=float,
        nargs=1,
        default=6.0,
    )

    # TODO create an update action

    return parser


if __name__ == "__main__":
    main()
