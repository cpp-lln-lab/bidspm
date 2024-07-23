#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from .parsers import bidspm_log, sub_command_parser

with open(Path(__file__).parent / "data" / "exit_codes.json") as f:
    EXIT_CODES = json.load(f)

log = bidspm_log(name="bidspm")

new_line = ", ...\n\t  "


def base_cmd(bids_dir: Path, output_dir: Path) -> str:
    cmd = f" bidspm( '{bids_dir}'{new_line}'{output_dir}'"
    return cmd


def append_main_cmd(cmd: str, analysis_level: str, action: str) -> str:
    cmd += f"{new_line}'{analysis_level}'{new_line}'action', '{action}'"
    return cmd


def end_cmd(cmd: str) -> str:
    cmd += ");  exit;"
    return cmd


def append_base_arguments(
    cmd: str,
    verbosity: str | int | None = None,
    space: list[str] | None = None,
    task: list[str] | str | None = None,
    ignore: list[str] | None = None,
    options: Path | None = None,
) -> str:
    """Append arguments common to all actions to the command string."""
    if task != "{''}":
        task = "{ '" + "', '".join(task) + "' }" if task is not None else None

    space = "{ '" + "', '".join(space) + "' }" if space is not None else None  # type: ignore
    ignore = "{ '" + "', '".join(ignore) + "' }" if ignore is not None else None  # type: ignore

    if verbosity is not None:
        cmd += f"{new_line}'verbosity', {verbosity}"
    if space:
        cmd += f"{new_line}'space', {space}"
    if task:
        cmd += f"{new_line}'task', {task}"
    if ignore:
        cmd += f"{new_line}'ignore', {ignore}"
    if options:
        cmd += f"{new_line}'options', '{str(options)}'"

    return cmd


def append_common_arguments(
    cmd: str,
    skip_validation: bool = False,
    dry_run: bool = False,
    fwhm: Any = 6,
    participant_label: list[str] | None = None,
    bids_filter_file: Path | None = None,
) -> str:
    """Append arguments common to preproc and stats."""
    participant_label = (
        "{ '" + "', '".join(participant_label) + "' }"  # type: ignore
        if participant_label is not None
        else None
    )

    if fwhm:
        cmd += f"{new_line}'fwhm', {fwhm}"
    if participant_label:
        cmd += f"{new_line}'participant_label', {participant_label}"
    if skip_validation:
        cmd += f"{new_line}'skip_validation', true"
    if dry_run:
        cmd += f"{new_line}'dry_run', true"
    if bids_filter_file:
        cmd += f"{new_line}'bids_filter_file', '{bids_filter_file}'"

    return cmd


def default_model(
    bids_dir: Path,
    output_dir: Path,
    analysis_level: str = "dataset",
    participant_label: list[str] | None = None,
    verbosity: str | int = 2,
    space: list[str] | None = None,
    task: list[str] | str | None = None,
    skip_validation: bool = False,
    bids_filter_file: Path | None = None,
    ignore: list[str] | None = None,
    options: Path | None = None,
) -> int | str:
    if task is None:
        task = "{''}"

    cmd = generate_cmd(
        bids_dir=bids_dir,
        output_dir=output_dir,
        analysis_level=analysis_level,
        action="default_model",
        verbosity=verbosity,
        space=space,
        task=task,
        ignore=ignore,
        options=options,
    )
    cmd = append_common_arguments(
        cmd=cmd,
        participant_label=participant_label,
        skip_validation=skip_validation,
        bids_filter_file=bids_filter_file,
    )
    cmd = end_cmd(cmd)

    log.info("Creating default model.")

    return cmd


def preprocess(
    bids_dir: Path,
    output_dir: Path,
    action: str,
    analysis_level: str = "subject",
    verbosity: str | int = 2,
    participant_label: list[str] | None = None,
    fwhm: Any = 6,
    dummy_scans: str | int | None = None,
    space: list[str] | None = None,
    task: list[str] | None = None,
    ignore: list[str] | None = None,
    anat_only: bool = False,
    skip_validation: bool = False,
    bids_filter_file: Path | None = None,
    dry_run: bool = False,
    options: Path | None = None,
    boilerplate_only: bool = False,
) -> int | str:
    cmd = generate_cmd(
        bids_dir=bids_dir,
        output_dir=output_dir,
        analysis_level=analysis_level,
        action=action,
        verbosity=verbosity,
        space=space,
        task=task,
        ignore=ignore,
        options=options,
    )
    cmd = append_common_arguments(
        cmd=cmd,
        fwhm=fwhm,
        participant_label=participant_label,
        skip_validation=skip_validation,
        dry_run=dry_run,
        bids_filter_file=bids_filter_file,
    )
    if anat_only:
        cmd += f"{new_line}'anat_only', true"
    if dummy_scans:
        cmd += f"{new_line}'dummy_scans', {dummy_scans}"
    if boilerplate_only:
        cmd += f"{new_line}'boilerplate_only', true"
    cmd = end_cmd(cmd)

    if action == "preprocess":
        log.info("Running preprocessing.")
        log.info("For typical fmri data, consider using fmriprep instead.")

    elif action == "smooth":
        log.info("Running smoothing.")

    return cmd


def create_roi(
    bids_dir: Path,
    output_dir: Path,
    analysis_level: str = "subject",
    preproc_dir: Path | None = None,
    verbosity: str | int = 2,
    participant_label: list[str] | None = None,
    roi_dir: Path | None = None,
    roi_atlas: str | None = "neuromorphometrics",
    roi_name: list[str] | None = None,
    space: list[str] | None = None,
    bids_filter_file: Path | None = None,
    options: Path | None = None,
) -> str:
    roi_name = "{ '" + "', '".join(roi_name) + "' }" if roi_name is not None else None  # type: ignore
    if roi_dir is None:
        roi_dir = output_dir

    cmd = generate_cmd(
        bids_dir=bids_dir,
        output_dir=output_dir,
        analysis_level=analysis_level,
        action="create_roi",
        verbosity=verbosity,
        space=space,
        options=options,
    )
    cmd = append_common_arguments(
        cmd=cmd,
        participant_label=participant_label,
        bids_filter_file=bids_filter_file,
        fwhm=None,
    )
    cmd += f"{new_line}'roi_atlas', '{roi_atlas}'"
    cmd += f"{new_line}'roi_name', {roi_name}"
    if roi_dir:
        cmd += f"{new_line}'roi_dir', '{roi_dir}'"
    if preproc_dir:
        cmd += f"{new_line}'preproc_dir', '{preproc_dir}'"
    cmd = end_cmd(cmd)

    log.info("Creating ROI.")

    return cmd


def stats(
    bids_dir: Path,
    output_dir: Path,
    analysis_level: str,
    action: str,
    preproc_dir: Path | None,
    model_file: Path | None,
    verbosity: str | int = 2,
    participant_label: list[str] | None = None,
    fwhm: Any = 6,
    space: list[str] | None = None,
    task: list[str] | None = None,
    ignore: list[str] | None = None,
    skip_validation: bool = False,
    bids_filter_file: Path | None = None,
    dry_run: bool = False,
    roi_based: bool = False,
    roi_dir: Path | None = None,
    roi_atlas: str | None = None,
    roi_name: list[str] | None = None,
    use_dummy_regressor: bool = False,
    concatenate: bool = False,
    design_only: bool = False,
    keep_residuals: bool = False,
    options: Path | None = None,
    boilerplate_only: bool = False,
) -> int | str:
    cmd = generate_cmd(
        bids_dir=bids_dir,
        output_dir=output_dir,
        analysis_level=analysis_level,
        action=action,
        verbosity=verbosity,
        space=space,
        task=task,
        ignore=ignore,
        options=options,
    )
    cmd = append_common_arguments(
        cmd=cmd,
        fwhm=fwhm,
        participant_label=participant_label,
        skip_validation=skip_validation,
        dry_run=dry_run,
        bids_filter_file=bids_filter_file,
    )
    cmd += f"{new_line}'preproc_dir', '{preproc_dir}'"
    cmd += f"{new_line}'model_file', '{model_file}'"
    if roi_based:
        cmd += f"{new_line}'roi_based', true"
        if roi_dir:
            cmd += f"{new_line}'roi_dir', '{roi_dir}'"
        roi_name = "{ '" + "', '".join(roi_name) + "' }" if roi_name is not None else None  # type: ignore
        if roi_name:
            cmd += f"{new_line}'roi_name', {roi_name}"
    if concatenate:
        cmd += f"{new_line}'concatenate', true"
    if design_only:
        cmd += f"{new_line}'design_only', true"
    if keep_residuals:
        cmd += f"{new_line}'keep_residuals', true"
    if boilerplate_only:
        cmd += f"{new_line}'boilerplate_only', true"
    if use_dummy_regressor:
        cmd += f"{new_line}'use_dummy_regressor', true"
    if roi_atlas:
        cmd += f"{new_line}'roi_atlas', '{roi_atlas}'"
    cmd = end_cmd(cmd)

    log.info(f"Running {action}.")

    return cmd


def bms(
    bids_dir: Path,
    output_dir: Path,
    analysis_level: str,
    action: str,
    models_dir: Path,
    verbosity: str | int = 2,
    participant_label: list[str] | None = None,
    fwhm: Any = 6,
    skip_validation: bool = False,
    bids_filter_file: Path | None = None,
    dry_run: bool = False,
    options: Path | None = None,
) -> int | str:
    cmd = generate_cmd(
        bids_dir=bids_dir,
        output_dir=output_dir,
        analysis_level=analysis_level,
        action=action,
        verbosity=verbosity,
        options=options,
    )
    cmd = append_common_arguments(
        cmd=cmd,
        fwhm=fwhm,
        participant_label=participant_label,
        skip_validation=skip_validation,
        dry_run=dry_run,
        bids_filter_file=bids_filter_file,
    )
    cmd += f"{new_line}'models_dir', '{models_dir}'"
    cmd = end_cmd(cmd)

    log.info(f"Running {action}.")

    return cmd


def generate_cmd(
    bids_dir: Path,
    output_dir: Path,
    analysis_level: str,
    action: str,
    verbosity: str | int = 2,
    space: list[str] | None = None,
    task: list[str] | str | None = None,
    ignore: list[str] | None = None,
    options: Path | None = None,
) -> str:
    cmd = base_cmd(bids_dir=bids_dir, output_dir=output_dir)
    cmd = append_main_cmd(cmd=cmd, analysis_level=analysis_level, action=action)
    cmd = append_base_arguments(
        cmd=cmd,
        verbosity=verbosity,
        space=space,
        task=task,
        ignore=ignore,
        options=options,
    )
    return cmd


def generate_command_default_model(argv: Any) -> int | str:
    parser = sub_command_parser()
    args = parser.parse_args(argv[1:])

    cmd = default_model(
        bids_dir=Path(args.bids_dir[0]).absolute(),
        output_dir=Path(args.output_dir[0]).absolute(),
        analysis_level=args.analysis_level[0],
        participant_label=args.participant_label,
        verbosity=_get_verbosity(args),
        bids_filter_file=_get_bids_filter_file(args),
        options=_get_options(args),
        task=args.task,
        space=args.space,
        skip_validation=args.skip_validation,
        ignore=args.ignore,
    )
    return cmd


def generate_command_create_roi(argv: Any) -> str:
    parser = sub_command_parser()
    args = parser.parse_args(argv[1:])

    if args.roi_dir is None or args.roi_dir[0] is None:
        roi_dir = args.output_dir[0]
    else:
        roi_dir = args.roi_dir[0]
    roi_dir = Path(roi_dir).absolute()

    cmd = create_roi(
        bids_dir=Path(args.bids_dir[0]).absolute(),
        output_dir=Path(args.output_dir[0]).absolute(),
        analysis_level=args.analysis_level[0],
        preproc_dir=_get_preproc_dir(args),
        verbosity=_get_verbosity(args),
        participant_label=args.participant_label,
        roi_dir=roi_dir,
        roi_atlas=_get_roi_atlas(args),
        roi_name=args.roi_name,
        space=args.space,
        bids_filter_file=_get_bids_filter_file(args),
        options=_get_options(args),
    )
    return cmd


def generate_command_smooth(argv: Any) -> int | str:
    parser = sub_command_parser()
    args = parser.parse_args(argv[1:])

    cmd = preprocess(
        bids_dir=Path(args.bids_dir[0]).absolute(),
        output_dir=Path(args.output_dir[0]).absolute(),
        analysis_level=args.analysis_level[0],
        action="smooth",
        participant_label=args.participant_label,
        verbosity=_get_verbosity(args),
        task=args.task,
        space=args.space,
        fwhm=_get_fwhm(args),
        anat_only=args.anat_only,
        bids_filter_file=_get_bids_filter_file(args),
        dry_run=args.dry_run,
        options=_get_options(args),
    )
    return cmd


def generate_command_preprocess(argv: Any) -> int | str:
    parser = sub_command_parser()
    args = parser.parse_args(argv[1:])

    cmd = preprocess(
        bids_dir=Path(args.bids_dir[0]).absolute(),
        output_dir=Path(args.output_dir[0]).absolute(),
        analysis_level=args.analysis_level[0],
        action="preprocess",
        participant_label=args.participant_label,
        verbosity=_get_verbosity(args),
        task=args.task,
        space=args.space,
        fwhm=_get_fwhm(args),
        anat_only=args.anat_only,
        bids_filter_file=_get_bids_filter_file(args),
        dry_run=args.dry_run,
        options=_get_options(args),
        ignore=args.ignore,
        boilerplate_only=args.boilerplate_only,
        dummy_scans=_get_dummy_scans(args),
        skip_validation=args.skip_validation,
    )
    return cmd


def generate_command_stats(argv: Any) -> int | str:
    parser = sub_command_parser()
    args = parser.parse_args(argv[1:])

    preproc_dir = _get_preproc_dir(args)
    if preproc_dir is None:
        log.error("No 'preproc_dir' was provided.")
        exit(EXIT_CODES["NOINPUT"]["Value"])
    if preproc_dir is not None and not preproc_dir.is_dir():
        log.error("The 'preproc_dir' does not exist:\n\t" f"{preproc_dir}")
        exit(EXIT_CODES["NOINPUT"]["Value"])

    roi_name = None
    roi_dir = None
    if args.roi_based:
        roi_name = args.roi_name
        roi_dir = Path(args.roi_dir[0]).absolute()

    cmd = stats(
        bids_dir=Path(args.bids_dir[0]).absolute(),
        output_dir=Path(args.output_dir[0]).absolute(),
        analysis_level=args.analysis_level[0],
        action="stats",
        preproc_dir=preproc_dir,
        model_file=Path(args.model_file[0]).absolute(),
        participant_label=args.participant_label,
        verbosity=_get_verbosity(args),
        space=args.space,
        fwhm=_get_fwhm(args),
        skip_validation=args.skip_validation,
        bids_filter_file=_get_bids_filter_file(args),
        dry_run=args.dry_run,
        concatenate=args.concatenate,
        options=_get_options(args),
        design_only=args.design_only,
        use_dummy_regressor=args.use_dummy_regressor,
        keep_residuals=args.keep_residuals,
        ignore=args.ignore,
        roi_based=args.roi_based,
        roi_name=roi_name,
        roi_dir=roi_dir,
        roi_atlas=_get_roi_atlas(args),
    )
    return cmd


def generate_command_contrasts(argv: Any) -> int | str:
    parser = sub_command_parser()
    args = parser.parse_args(argv[1:])

    preproc_dir = _get_preproc_dir(args)
    if preproc_dir is None:
        preproc_dir = Path().absolute()

    cmd = stats(
        bids_dir=Path(args.bids_dir[0]).absolute(),
        output_dir=Path(args.output_dir[0]).absolute(),
        analysis_level=args.analysis_level[0],
        action="contrasts",
        preproc_dir=preproc_dir,
        model_file=Path(args.model_file[0]).absolute(),
        participant_label=args.participant_label,
        verbosity=_get_verbosity(args),
        space=args.space,
        fwhm=_get_fwhm(args),
        skip_validation=args.skip_validation,
        bids_filter_file=_get_bids_filter_file(args),
        dry_run=args.dry_run,
        concatenate=args.concatenate,
        options=_get_options(args),
    )
    return cmd


def generate_command_results(argv: Any) -> int | str:
    parser = sub_command_parser()
    args = parser.parse_args(argv[1:])

    preproc_dir = _get_preproc_dir(args)
    if preproc_dir is None:
        preproc_dir = Path().absolute()

    cmd = stats(
        bids_dir=Path(args.bids_dir[0]).absolute(),
        output_dir=Path(args.output_dir[0]).absolute(),
        analysis_level=args.analysis_level[0],
        action="results",
        preproc_dir=preproc_dir,
        model_file=Path(args.model_file[0]).absolute(),
        participant_label=args.participant_label,
        verbosity=_get_verbosity(args),
        space=args.space,
        fwhm=_get_fwhm(args),
        skip_validation=args.skip_validation,
        bids_filter_file=_get_bids_filter_file(args),
        dry_run=args.dry_run,
        options=_get_options(args),
        roi_atlas=_get_roi_atlas(args),
    )
    return cmd


def generate_command_bms(argv: Any) -> int | str:
    parser = sub_command_parser()
    args = parser.parse_args(argv[1:])

    cmd = bms(
        bids_dir=Path(args.bids_dir[0]).absolute(),
        output_dir=Path(args.output_dir[0]).absolute(),
        analysis_level=args.analysis_level[0],
        action="bms",
        models_dir=Path(args.models_dir[0]).absolute(),
        participant_label=args.participant_label,
        verbosity=_get_verbosity(args),
        fwhm=_get_fwhm(args),
        skip_validation=args.skip_validation,
        bids_filter_file=_get_bids_filter_file(args),
        dry_run=args.dry_run,
        options=_get_options(args),
    )
    return cmd


def _get_verbosity(args: Any) -> str | int:
    if isinstance(args.verbosity, list):
        return args.verbosity[0]
    else:
        return args.verbosity


def _get_roi_atlas(args: Any) -> str:
    if isinstance(args.roi_atlas, list):
        return args.roi_atlas[0]
    else:
        return args.roi_atlas


def _get_fwhm(args: Any) -> str | int:
    if isinstance(args.fwhm, list):
        return args.fwhm[0]
    else:
        return args.fwhm


def _get_dummy_scans(args: Any) -> int | str:
    if isinstance(args.dummy_scans, list):
        return args.dummy_scans[0]
    else:
        return args.dummy_scans


def _get_options(args: Any) -> Path | None:
    return Path(args.options[0]).absolute() if args.options is not None else None


def _get_bids_filter_file(args: Any) -> Path | None:
    return (
        Path(args.bids_filter_file[0]).absolute()
        if args.bids_filter_file is not None
        else None
    )


def _get_preproc_dir(args: Any) -> Path | None:
    return Path(args.preproc_dir[0]).absolute() if args.preproc_dir is not None else None
