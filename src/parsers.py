import argparse
import logging
from pathlib import Path
from typing import IO
from typing import Optional

import rich
from rich.logging import RichHandler

log = logging.getLogger("bidspm")

version_file = Path(__file__).parent.parent.joinpath("version.txt")

with open(version_file) as f:
    __version__ = f.read().strip()


def bidspm_log(name: str = "bidspm") -> logging.Logger:
    """Create log."""
    FORMAT = "bidspm - %(asctime)s - %(levelname)s - %(message)s"

    if not name:
        name = "rich"

    logging.basicConfig(
        level="INFO", format=FORMAT, datefmt="[%X]", handlers=[RichHandler()]
    )

    return logging.getLogger(name)


class MuhParser(argparse.ArgumentParser):
    def _print_message(self, message: str, file: Optional[IO[str]] = None) -> None:
        rich.print(message, file=file)


def common_parser():

    parser = MuhParser(
        description="bidspm is a SPM base BIDS app",
        epilog="""
        \n- all parameters use ``snake_case``,
        \n- most "invalid" calls simply initialize bidspm.

        For a more readable version of this help section,
        see the online https://bidspm.readthedocs.io/en/latest/usage_notes.html.
        """,
    )

    parser.add_argument(
        "-v",
        "--version",
        action="version",
        version=f"{__version__}",
    )
    parser.add_argument(
        "bids_dir",
        help="""
        Fullpath to the directory with the input dataset
        formatted according to the BIDS standard.
        """,
        nargs=1,
    )
    parser.add_argument(
        "output_dir",
        help="""
        Fullpath to the directory where the output files will be stored.
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
        Action to perform.

        - ``preprocess``
        - ``default_model``
        - ``stats``: runs model specification / estimation, contrast computation, display results
        - ``contrasts``: contrast computation, display results
        - ``results``: display results
        """,
        choices=["preprocess", "default_model", "stats", "contrasts", "results"],
        required=True,
        type=str,
        nargs=1,
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
        "--task",
        help="""
        Tasks of the input data.
        """,
        type=str,
        nargs="+",
    )
    parser.add_argument(
        "--space",
        help="""
        Space of the input data.
        """,
        default=["IXI549Space"],
        type=str,
        nargs="+",
    )
    parser.add_argument(
        "--ignore",
        help="""
        If preprocessing should be done only on anatomical data.
        """,
        choices=[
            "contrasts",
            "transformations",
            "qa",
            "fieldmaps",
            "slicetiming",
            "unwarp",
        ],
        nargs="+",
    )

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
        action="store_true",
        default=False,
    )
    parser.add_argument(
        "--bids_filter_file",
        help="""
        Fullpath to a JSON file describing custom BIDS input filters.
        """,
        type=str,
        nargs=1,
    )
    parser.add_argument(
        "--fwhm",
        help="""
        The full width at half maximum of the gaussian kernel to apply to the preprocessed data
        or to use as inputs for the statistical analysis.
        """,
        type=float,
        nargs=1,
        default=6.0,
    )
    parser.add_argument(
        "--options",
        help="""
        Path to JSON file containing bidspm options.
        """,
    )
    parser.add_argument(
        "--skip_validation",
        help="""
        To skip BIDS dataset and BIDS stats model validation.
        """,
        action="store_true",
        default=False,
    )
    parser.add_argument(
        "--preproc_dir",
        help="""
        Fullpath to the directory with the preprocessed data.
        """,
        type=str,
        nargs=1,
    )
    parser.add_argument(
        "--model_file",
        help="""
        Path to BIDS stats model.
        """,
        type=str,
        nargs=1,
    )
    parser.add_argument(
        "--roi_based",
        help="""
        To run stats only in regions of interests.
        """,
        action="store_true",
        default=False,
    )
    parser.add_argument(
        "--design_only",
        help="""
        To only specify the GLM without estimating it.
        """,
        action="store_true",
        default=False,
    )
    parser.add_argument(
        "--concatenate",
        help="""
        To create 4D image of all the beta images from the conditions of interest.
        """,
        action="store_true",
        default=False,
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
    parser.add_argument(
        "--anat_only",
        help="""
        If preprocessing should be done only on anatomical data.
        """,
        action="store_true",
        default=False,
    )

    return parser


def validate_parser():

    parser = argparse.ArgumentParser(
        description="validate bids stats model",
    )

    parser.add_argument(
        "model",
        help="""
        The bids stats model file. If a directory is provided,
        all files ending in '_smdl.json' will be validated.
        """,
        nargs=1,
    )

    return parser
