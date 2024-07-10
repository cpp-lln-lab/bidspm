from __future__ import annotations

import argparse
import json
import logging
from pathlib import Path

from rich.logging import RichHandler
from rich_argparse import RichHelpFormatter

from ._version import __version__  # type ignore

log = logging.getLogger("bidspm")

with open(Path(__file__).parent / "data" / "allowed_actions.json") as f:
    ALLOWED_ACTIONS = json.load(f)


def bidspm_log(name: str = "bidspm") -> logging.Logger:
    """Create log."""
    FORMAT = "bidspm - %(asctime)s - %(levelname)s - %(message)s"

    if not name:
        name = "rich"

    logging.basicConfig(
        level="INFO", format=FORMAT, datefmt="[%X]", handlers=[RichHandler()]
    )

    return logging.getLogger(name)


def common_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="bidspm is a SPM base BIDS app",
        epilog="""
        \n- all parameters use ``snake_case``,

        \n- most "invalid" calls simply initialize bidspm.

        For a more readable version of this help section,
        see the online https://bidspm.readthedocs.io/en/latest/usage_notes.html.
        """,
        formatter_class=RichHelpFormatter,
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
        """,
        choices=ALLOWED_ACTIONS,
        required=True,
        type=str,
        nargs=1,
    )
    parser.add_argument(
        "--verbosity",
        help="""
        Verbosity level.
        """,
        choices=[0, 1, 2, 3],
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
        To specify steps to skip.
        """,
        choices=[
            "fieldmaps",
            "slicetiming",
            "unwarp",
            "qa",
            "contrasts",
            "transformations",
            "dataset",
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
        "--boilerplate_only",
        help="""
        When set to ``true`` this will only generate figures describing the raw data,
        the methods section boilerplate.
        """,
        action="store_true",
        default=False,
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
        "--roi_dir",
        help="""
        Fullpath to the directory with the regions of interest.
        """,
        type=str,
        nargs=1,
    )
    parser.add_argument(
        "--roi_name",
        help="""
        Name of the roi to create. If the ROI does not exist in the atlas,
        the list of available ROI will be returned in the error message.
        """,
        nargs="+",
    )

    preprocess_only = parser.add_argument_group("preprocess only arguments")
    preprocess_only.add_argument(
        "--anat_only",
        help="""
        If preprocessing should be done only on anatomical data.
        """,
        action="store_true",
        default=False,
    )
    preprocess_only.add_argument(
        "--dummy_scans",
        help="""
        Number of dummy scans to remove.
        """,
        type=int,
        nargs=1,
        default=0,
    )

    create_roi_only = parser.add_argument_group("create_roi and stats only arguments")
    create_roi_only.add_argument(
        "--roi_atlas",
        help="""
        Atlas to create the regions of interest from.
        """,
        type=str,
        nargs=1,
        default="neuromorphometrics",
        choices=["neuromorphometrics", "wang", "anatomy_toobox", "visfatlas", "hcpex"],
    )

    stats_only = parser.add_argument_group("stats only arguments")
    stats_only.add_argument(
        "--model_file",
        help="""
        Fullpath to BIDS stats model.
        """,
        type=str,
        nargs=1,
    )
    stats_only.add_argument(
        "--preproc_dir",
        help="""
        Fullpath to the directory with the preprocessed data.
        """,
        type=str,
        nargs=1,
    )
    stats_only.add_argument(
        "--keep_residuals",
        help="""
        Keep GLM residuals.
        """,
        action="store_true",
        default=False,
    )
    stats_only.add_argument(
        "--concatenate",
        help="""
        To create 4D image of all the beta and contrast images of the conditions
        of interest included in the run level design matrix.
        """,
        action="store_true",
        default=False,
    )
    stats_only.add_argument(
        "--design_only",
        help="""
        To only specify the GLM without estimating it.
        """,
        action="store_true",
        default=False,
    )
    stats_only.add_argument(
        "--roi_based",
        help="""
        To run stats only in regions of interests.
        """,
        action="store_true",
        default=False,
    )

    return parser


def validate_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="validate bids stats model", formatter_class=RichHelpFormatter
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
