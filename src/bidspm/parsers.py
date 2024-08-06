from __future__ import annotations

import json
import logging
from argparse import ArgumentParser
from pathlib import Path

from rich.logging import RichHandler
from rich_argparse import RichHelpFormatter

from ._version import __version__  # type ignore

log = logging.getLogger("bidspm")

with open(Path(__file__).parent / "data" / "allowed_actions.json") as f:
    ALLOWED_ACTIONS = json.load(f)

SUPPORTED_ATLASES = {
    "anatomy_toobox",
    "glasser",
    "hcpex",
    "neuromorphometrics",
    "visfatlas",
    "wang",
}


def bidspm_log(name: str = "bidspm") -> logging.Logger:
    """Create log."""
    FORMAT = "bidspm - %(asctime)s - %(levelname)s - %(message)s"

    if not name:
        name = "rich"

    logging.basicConfig(
        level="INFO", format=FORMAT, datefmt="[%X]", handlers=[RichHandler()]
    )

    return logging.getLogger(name)


def _base_parser() -> ArgumentParser:
    parser = ArgumentParser(
        description="bidspm is a SPM base BIDS app",
        epilog="""
        All parameters use ``snake_case``.
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
        Level of the analysis that wsub_command_parserill be performed.
        Multiple participant level analyses can be run independently
        (in parallel) using the same ``output_dir``.
        """,
        choices=["subject", "dataset"],
        type=str,
        nargs=1,
    )

    return parser


def _add_common_arguments(
    parser: ArgumentParser,
) -> ArgumentParser:
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
        "--bids_filter_file",
        help="""
        Fullpath to a JSON file describing custom BIDS input filters.
        """,
        type=str,
        nargs=1,
    )

    parser.add_argument(
        "--options",
        help="""
        Path to JSON file containing bidspm options.
        """,
        type=str,
        nargs=1,
    )

    return parser


def _add_common_stats_arguments(
    parser: ArgumentParser,
) -> ArgumentParser:
    parser.add_argument(
        "--model_file",
        help="""
        Fullpath to BIDS stats model.
        """,
        type=str,
        nargs=1,
        required=True,
    )
    parser = _add_preproc_dir(parser)
    parser = _add_task(parser)
    parser = _add_space(parser)
    parser = _add_fwhm(parser)
    parser = _add_dry_run(parser)
    parser = _add_skip_validation(parser)
    parser = _add_boilerplate_only(parser)
    return parser


def sub_command_parser() -> ArgumentParser:
    parser = _base_parser()
    subparsers = parser.add_subparsers(
        dest="command",
        help="Choose a subcommand",
        required=True,
    )

    preproc_parser = subparsers.add_parser(
        "preprocess",
        help="""Preprocessing""",
        formatter_class=parser.formatter_class,
    )
    preproc_parser = _add_common_arguments(preproc_parser)
    preproc_parser = _add_boilerplate_only(preproc_parser)
    preproc_parser = _add_anat_only(preproc_parser)
    preproc_parser.add_argument(
        "--dummy_scans",
        help="""
        Number of dummy scans to remove.
        """,
        type=int,
        nargs=1,
        default=0,
    )
    preproc_parser = _add_task(preproc_parser)
    preproc_parser = _add_space(preproc_parser)
    preproc_parser = _add_fwhm(preproc_parser)
    preproc_parser = _add_dry_run(preproc_parser)
    preproc_parser = _add_skip_validation(preproc_parser)
    preproc_parser.add_argument(
        "--ignore",
        help="""
        To specify steps to skip.
        """,
        choices=["fieldmaps", "slicetiming", "unwarp", "qa"],
        nargs="+",
    )

    smooth_parser = subparsers.add_parser(
        "smooth",
        help="""Smooth""",
        formatter_class=parser.formatter_class,
    )
    smooth_parser = _add_common_arguments(smooth_parser)
    smooth_parser = _add_task(smooth_parser)
    smooth_parser = _add_space(smooth_parser)
    smooth_parser = _add_fwhm(smooth_parser)
    smooth_parser = _add_anat_only(smooth_parser)
    smooth_parser = _add_dry_run(smooth_parser)

    default_parser = subparsers.add_parser(
        "default_model",
        help="""Create default model""",
        formatter_class=parser.formatter_class,
    )
    default_parser = _add_common_arguments(default_parser)
    default_parser = _add_task(default_parser)
    default_parser = _add_space(default_parser)
    default_parser = _add_skip_validation(default_parser)
    default_parser.add_argument(
        "--ignore",
        help="""
        To specify steps to skip.
        """,
        choices=["Transformations", "Contrasts", "Dataset"],
        nargs="+",
    )

    roi_parser = subparsers.add_parser(
        "create_roi",
        help="""Create ROIs""",
        formatter_class=parser.formatter_class,
    )
    roi_parser = _add_common_arguments(roi_parser)
    roi_parser = _add_boilerplate_only(roi_parser)
    roi_parser = _add_space(roi_parser)
    roi_parser.add_argument(
        "--roi_name",
        help="""
        Name of the roi to create. If the ROI does not exist in the atlas,
        the list of available ROI will be returned in the error message.
        """,
        nargs="+",
        required=True,
    )
    roi_parser = _add_roi_atlas(roi_parser)
    roi_parser = _add_preproc_dir(roi_parser)
    roi_parser.add_argument(
        "--hemisphere",
        help="""
        To specify steps to skip.
        """,
        choices=["L", "R"],
        nargs="+",
    )

    # %% STATS
    stats_parser = subparsers.add_parser(
        "stats",
        help="""Specify and estimate GLM, compute contrasts and get results""",
        formatter_class=parser.formatter_class,
    )
    stats_parser = _add_common_arguments(stats_parser)
    stats_parser = _add_common_stats_arguments(stats_parser)
    stats_parser = _add_keep_residuals(stats_parser)
    stats_parser = _add_design_only(stats_parser)
    stats_parser.add_argument(
        "--use_dummy_regressor",
        help="""
        If true any missing condition will be modelled
by a dummy regressor of ``NaN``.
        """,
        action="store_true",
        default=False,
    )
    stats_parser.add_argument(
        "--ignore",
        help="""
        To specify steps to skip.
        """,
        choices=["qa"],
        nargs="+",
    )
    stats_parser.add_argument(
        "--roi_based",
        help="""
        Use to run a ROI-based analysis.
        """,
        action="store_true",
        default=False,
    )
    stats_parser.add_argument(
        "--roi_dir",
        help="""
        Fullpath to the directory with the regions of interest.
        """,
        type=str,
        nargs=1,
    )
    stats_parser.add_argument(
        "--roi_name",
        help="""
        Name of the roi to create. If the ROI does not exist in the atlas,
        the list of available ROI will be returned in the error message.
        """,
        nargs="+",
    )
    stats_parser.add_argument(
        "--node_name",
        help="""
        Model node to run.
        """,
        type=str,
        nargs=1,
    )
    stats_parser.add_argument(
        "--concatenate",
        help="""
        To create 4D image of all the beta and contrast images of the conditions
        of interest included in the run level design matrix.
        """,
        action="store_true",
        default=False,
    )
    stats_parser = _add_roi_atlas(stats_parser)

    contrasts_parser = subparsers.add_parser(
        "contrasts",
        help="""Compute contrasts and get results""",
        formatter_class=parser.formatter_class,
    )
    contrasts_parser = _add_common_arguments(contrasts_parser)
    contrasts_parser = _add_common_stats_arguments(contrasts_parser)
    contrasts_parser.add_argument(
        "--concatenate",
        help="""
        To create 4D image of all the beta and contrast images of the conditions
        of interest included in the run level design matrix.
        """,
        action="store_true",
        default=False,
    )

    results_parser = subparsers.add_parser(
        "results",
        help="""Get results""",
        formatter_class=parser.formatter_class,
    )
    results_parser = _add_common_arguments(results_parser)
    results_parser = _add_common_stats_arguments(results_parser)
    results_parser = _add_roi_atlas(results_parser)

    # BMS
    bms_parser = subparsers.add_parser(
        "bms",
        help="""Run bayesian model selection""",
        formatter_class=parser.formatter_class,
    )
    bms_parser = _add_common_arguments(bms_parser)
    bms_parser.add_argument(
        "--models_dir",
        help="""
        Fullpath to the directory with the models.
        """,
        type=str,
        nargs=1,
        required=True,
    )
    bms_parser = _add_fwhm(bms_parser)
    bms_parser = _add_dry_run(bms_parser)
    bms_parser = _add_skip_validation(bms_parser)

    return parser


def _add_dry_run(parser: ArgumentParser) -> ArgumentParser:
    parser.add_argument(
        "--dry_run",
        help="""
        When set to ``true`` this will generate and save the SPM batches,
        but not actually run them.
        """,
        action="store_true",
        default=False,
    )
    return parser


def _add_preproc_dir(parser: ArgumentParser) -> ArgumentParser:
    parser.add_argument(
        "--preproc_dir",
        help="""
        Fullpath to the directory with the preprocessed data.
        """,
        type=str,
        nargs=1,
    )
    return parser


def _add_fwhm(parser: ArgumentParser) -> ArgumentParser:
    parser.add_argument(
        "--fwhm",
        help="""
The full width at half maximum of the gaussian kernel
to apply to the preprocessed data
or to use as inputs for the statistical analysis.
        """,
        type=float,
        nargs=1,
        default=6.0,
    )
    return parser


def _add_skip_validation(parser: ArgumentParser) -> ArgumentParser:
    parser.add_argument(
        "--skip_validation",
        help="""
        To skip BIDS dataset and BIDS stats model validation.
        """,
        action="store_true",
        default=False,
    )
    return parser


def _add_task(parser: ArgumentParser) -> ArgumentParser:
    parser.add_argument(
        "--task",
        help="""
        Tasks of the input data.
        """,
        type=str,
        nargs="+",
    )
    return parser


def _add_space(parser: ArgumentParser) -> ArgumentParser:
    parser.add_argument(
        "--space",
        help="""
        Space of the input data.
        """,
        default=["IXI549Space"],
        type=str,
        nargs="+",
    )
    return parser


def _add_boilerplate_only(parser: ArgumentParser) -> ArgumentParser:
    parser.add_argument(
        "--boilerplate_only",
        help="""
        When set to ``true`` this will only generate figures describing the raw data,
        the methods section boilerplate.
        """,
        action="store_true",
        default=False,
    )
    return parser


def _add_roi_atlas(parser: ArgumentParser) -> ArgumentParser:
    parser.add_argument(
        "--roi_atlas",
        help="""
        Atlas to create the regions of interest from.
        """,
        type=str,
        nargs=1,
        default="neuromorphometrics",
        choices=list(SUPPORTED_ATLASES),
    )
    return parser


def _add_keep_residuals(parser: ArgumentParser) -> ArgumentParser:
    parser.add_argument(
        "--keep_residuals",
        help="""
        Keep GLM residuals.
        """,
        action="store_true",
        default=False,
    )
    return parser


def _add_design_only(parser: ArgumentParser) -> ArgumentParser:
    parser.add_argument(
        "--design_only",
        help="""
        To only specify the GLM without estimating it.
        """,
        action="store_true",
        default=False,
    )
    return parser


def _add_anat_only(parser: ArgumentParser) -> ArgumentParser:
    parser.add_argument(
        "--anat_only",
        help="""
        If preprocessing should be done only on anatomical data.
        """,
        action="store_true",
        default=False,
    )
    return parser


def validate_parser() -> ArgumentParser:
    parser = ArgumentParser(
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
