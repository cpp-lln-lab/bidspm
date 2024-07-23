from __future__ import annotations

import json
import logging
from argparse import ArgumentParser, _ArgumentGroup
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


def base_parser() -> ArgumentParser:
    parser = ArgumentParser(
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

    return parser


def add_common_arguments(
    parser: ArgumentParser | _ArgumentGroup,
) -> ArgumentParser | _ArgumentGroup:
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


def add_common_stats_arguments(
    parser: ArgumentParser | _ArgumentGroup,
) -> ArgumentParser | _ArgumentGroup:
    parser.add_argument(
        "--model_file",
        help="""
        Fullpath to BIDS stats model.
        """,
        type=str,
        nargs=1,
    )
    parser = add_preproc_dir(parser)

    parser = add_boilerplate_only(parser)
    return parser


def add_preproc_dir(parser):
    parser.add_argument(
        "--preproc_dir",
        help="""
        Fullpath to the directory with the preprocessed data.
        """,
        type=str,
        nargs=1,
    )
    return parser


def add_preproc_arguments(
    parser: ArgumentParser | _ArgumentGroup,
) -> ArgumentParser | _ArgumentGroup:
    parser.add_argument(
        "--anat_only",
        help="""
        If preprocessing should be done only on anatomical data.
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
    return parser


def sub_command_parser() -> ArgumentParser:
    parser = base_parser()
    subparsers = parser.add_subparsers(
        dest="command",
        help="Choose a subcommand",
        required=True,
    )

    default_parser = subparsers.add_parser(
        "default_model",
        help="""Create default model""",
        formatter_class=parser.formatter_class,
    )
    default_parser = add_common_arguments(default_parser)
    default_parser = add_task(default_parser)
    default_parser = add_space(default_parser)
    default_parser = add_skip_validation(default_parser)
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
    roi_parser = add_common_arguments(roi_parser)
    roi_parser = add_boilerplate_only(roi_parser)
    roi_parser = add_space(roi_parser)
    roi_parser = add_roi_dir(roi_parser)
    roi_parser = add_roi_name(roi_parser)
    roi_parser = add_roi_atlas(roi_parser)
    roi_parser = add_preproc_dir(roi_parser)
    roi_parser.add_argument(
        "--hemisphere",
        help="""
        To specify steps to skip.
        """,
        choices=["L", "R"],
        nargs="+",
    )

    preproc_parser = subparsers.add_parser(
        "preprocess",
        help="""Preprocessing""",
        formatter_class=parser.formatter_class,
    )
    preproc_parser = add_common_arguments(preproc_parser)
    preproc_parser = add_boilerplate_only(preproc_parser)
    preproc_parser = add_preproc_arguments(preproc_parser)
    preproc_parser = add_task(preproc_parser)
    preproc_parser = add_space(preproc_parser)
    preproc_parser = add_fwhm(preproc_parser)
    preproc_parser = add_dry_run(preproc_parser)
    preproc_parser = add_skip_validation(preproc_parser)
    preproc_parser.add_argument(
        "--ignore",
        help="""
        To specify steps to skip.
        """,
        choices=["fieldmaps", "slicetiming", "unwarp", "qa"],
        nargs="+",
    )

    # %% STATS
    stats_parser = subparsers.add_parser(
        "stats",
        help="""Run stats""",
        formatter_class=parser.formatter_class,
    )
    stats_parser = add_common_arguments(stats_parser)
    stats_parser = add_common_stats_arguments(stats_parser)
    stats_parser = add_task(stats_parser)
    stats_parser = add_space(stats_parser)
    stats_parser = add_fwhm(stats_parser)
    stats_parser = add_dry_run(stats_parser)
    stats_parser = add_skip_validation(stats_parser)
    stats_parser = add_keep_residuals(stats_parser)
    stats_parser = add_design_only(stats_parser)
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
    stats_parser = add_roi_dir(stats_parser)
    stats_parser = add_roi_name(stats_parser)
    stats_parser.add_argument(
        "--node_name",
        help="""
        Model node to run.
        """,
        type=str,
        nargs=1,
    )

    contrasts_parser = subparsers.add_parser(
        "contrasts",
        help="""Compute contrasts""",
        formatter_class=parser.formatter_class,
    )
    contrasts_parser = add_common_arguments(contrasts_parser)
    contrasts_parser = add_common_stats_arguments(contrasts_parser)
    contrasts_parser = add_task(contrasts_parser)
    contrasts_parser = add_space(contrasts_parser)
    contrasts_parser = add_fwhm(contrasts_parser)
    contrasts_parser = add_dry_run(contrasts_parser)
    contrasts_parser = add_skip_validation(contrasts_parser)
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
    results_parser = add_common_arguments(results_parser)
    results_parser = add_common_stats_arguments(results_parser)
    results_parser = add_task(results_parser)
    results_parser = add_space(results_parser)
    results_parser = add_fwhm(results_parser)
    results_parser = add_dry_run(results_parser)
    results_parser = add_skip_validation(results_parser)
    results_parser = add_roi_atlas(results_parser)

    # BMS
    bms_parser = subparsers.add_parser(
        "bms",
        help="""Run bayesian model selection""",
        formatter_class=parser.formatter_class,
    )
    bms_parser = add_common_arguments(bms_parser)
    bms_parser.add_argument(
        "--models_dir",
        help="""
        Fullpath to the directory with the models.
        """,
        type=str,
        nargs=1,
    )
    bms_parser = add_fwhm(bms_parser)
    bms_parser = add_dry_run(bms_parser)
    bms_parser = add_skip_validation(bms_parser)

    return parser


def common_parser() -> ArgumentParser:
    parser = base_parser()

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

    parser = add_common_arguments(parser)
    parser = add_task(parser)
    parser = add_space(parser)
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

    parser = add_dry_run(parser)

    parser = add_fwhm(parser)

    parser = add_skip_validation(parser)

    parser = add_roi_dir(parser)
    parser = add_roi_name(parser)

    preprocess_only = parser.add_argument_group("preprocess only arguments")
    preprocess_only = add_preproc_arguments(preprocess_only)

    create_roi_only = parser.add_argument_group("create_roi and stats only arguments")
    create_roi_only = add_roi_atlas(create_roi_only)

    stats_only = parser.add_argument_group("stats only arguments")
    stats_only = add_common_stats_arguments(stats_only)
    stats_only = add_keep_residuals(stats_only)
    stats_only = add_concatenate(stats_only)
    stats_only = add_design_only(stats_only)
    stats_only = add_roi_based(stats_only)

    return parser


def add_dry_run(
    parser: ArgumentParser | _ArgumentGroup,
) -> ArgumentParser | _ArgumentGroup:
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


def add_fwhm(parser: ArgumentParser | _ArgumentGroup) -> ArgumentParser | _ArgumentGroup:
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
    return parser


def add_skip_validation(
    parser: ArgumentParser | _ArgumentGroup,
) -> ArgumentParser | _ArgumentGroup:
    parser.add_argument(
        "--skip_validation",
        help="""
        To skip BIDS dataset and BIDS stats model validation.
        """,
        action="store_true",
        default=False,
    )
    return parser


def add_roi_dir(
    parser: ArgumentParser | _ArgumentGroup,
) -> ArgumentParser | _ArgumentGroup:
    parser.add_argument(
        "--roi_dir",
        help="""
        Fullpath to the directory with the regions of interest.
        """,
        type=str,
        nargs=1,
    )
    return parser


def add_roi_name(
    parser: ArgumentParser | _ArgumentGroup,
) -> ArgumentParser | _ArgumentGroup:
    parser.add_argument(
        "--roi_name",
        help="""
        Name of the roi to create. If the ROI does not exist in the atlas,
        the list of available ROI will be returned in the error message.
        """,
        nargs="+",
    )
    return parser


def add_task(parser: ArgumentParser | _ArgumentGroup) -> ArgumentParser | _ArgumentGroup:
    parser.add_argument(
        "--task",
        help="""
        Tasks of the input data.
        """,
        type=str,
        nargs="+",
    )
    return parser


def add_space(parser: ArgumentParser | _ArgumentGroup) -> ArgumentParser | _ArgumentGroup:
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


def add_boilerplate_only(
    parser: ArgumentParser | _ArgumentGroup,
) -> ArgumentParser | _ArgumentGroup:
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


def add_roi_atlas(
    parser: ArgumentParser | _ArgumentGroup,
) -> ArgumentParser | _ArgumentGroup:
    parser.add_argument(
        "--roi_atlas",
        help="""
        Atlas to create the regions of interest from.
        """,
        type=str,
        nargs=1,
        default="neuromorphometrics",
        choices=SUPPORTED_ATLASES,
    )
    return parser


def add_keep_residuals(
    parser: ArgumentParser | _ArgumentGroup,
) -> ArgumentParser | _ArgumentGroup:
    parser.add_argument(
        "--keep_residuals",
        help="""
        Keep GLM residuals.
        """,
        action="store_true",
        default=False,
    )
    return parser


def add_concatenate(
    parser: ArgumentParser | _ArgumentGroup,
) -> ArgumentParser | _ArgumentGroup:
    parser.add_argument(
        "--concatenate",
        help="""
        To create 4D image of all the beta and contrast images of the conditions
        of interest included in the run level design matrix.
        """,
        action="store_true",
        default=False,
    )
    return parser


def add_design_only(
    parser: ArgumentParser | _ArgumentGroup,
) -> ArgumentParser | _ArgumentGroup:
    parser.add_argument(
        "--design_only",
        help="""
        To only specify the GLM without estimating it.
        """,
        action="store_true",
        default=False,
    )
    return parser


def add_roi_based(
    parser: ArgumentParser | _ArgumentGroup,
) -> ArgumentParser | _ArgumentGroup:
    parser.add_argument(
        "--roi_based",
        help="""
        To run stats only in regions of interests.
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
