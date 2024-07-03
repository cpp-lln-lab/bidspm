# mypy: ignore-errors
from __future__ import annotations

from pathlib import Path

import pytest

from bidspm.bidspm import (
    append_base_arguments,
    append_common_arguments,
    base_cmd,
    bidspm,
    create_roi,
    default_model,
    preprocess,
    run_command,
    stats,
)
from bidspm.parsers import common_parser


def test_base_cmd():
    """Test base_cmd."""
    bids_dir = Path("/path/to/bids")
    output_dir = Path("/path/to/output")
    cmd = base_cmd(bids_dir, output_dir)
    assert cmd == " bidspm(); bidspm('/path/to/bids', ...\n\t\t\t '/path/to/output'"


def test_parser():
    """Test parser."""
    parser = common_parser()
    assert parser.description == "bidspm is a SPM base BIDS app"

    args, _ = parser.parse_known_args(
        [
            "/path/to/bids",
            "/path/to/output",
            "subject",
            "--action",
            "preprocess",
            "--task",
            "foo",
            "bar",
        ]
    )

    assert args.task == ["foo", "bar"]


def test_append_common_arguments():
    cmd = append_common_arguments(
        cmd="",
        fwhm=6,
        participant_label=["01", "02"],
        skip_validation=True,
        dry_run=True,
    )
    assert (
        cmd
        == ", ...\n\t\t\t 'fwhm', 6, ...\n\t\t\t 'participant_label', { '01', '02' }, ...\n\t\t\t 'skip_validation', true, ...\n\t\t\t 'dry_run', true"
    )


def test_append_base_arguments():
    cmd = append_base_arguments(
        cmd="", verbosity=0, space=["foo", "bar"], task=["spam", "eggs"], ignore=["nii"]
    )
    assert (
        cmd
        == ", ...\n\t\t\t 'verbosity', 0, ...\n\t\t\t 'space', { 'foo', 'bar' }, ...\n\t\t\t 'task', { 'spam', 'eggs' }, ...\n\t\t\t 'ignore', { 'nii' }"
    )


def test_run_command():
    """Test run_command."""
    cmd = "disp('hello'); exit();"
    return_code = run_command(cmd, platform="octave")
    assert return_code == 0


def test_bidspm_error_dir(caplog):
    return_code = bidspm(
        bids_dir=Path("/foo/bar"),
        output_dir=Path,
        analysis_level="subject",
        action="preprocess",
    )
    assert return_code == 1
    assert ["The 'bids_dir' does not exist:\n\t/foo/bar"] == [
        rec.message for rec in caplog.records
    ]


def test_bidspm_error_action(caplog):
    return_code = bidspm(
        bids_dir=Path(),
        output_dir=Path,
        analysis_level="subject",
        action="spam",
    )
    assert return_code == 1
    assert ["\nunknown action: spam"] == [rec.message for rec in caplog.records]


@pytest.mark.parametrize(
    "action",
    [
        "preprocess",
        "smooth",
    ],
)
@pytest.mark.parametrize("dry_run", [True, False])
@pytest.mark.parametrize("skip_validation", [True, False])
@pytest.mark.parametrize("anat_only", [True, False])
def test_preprocess(action, dry_run, skip_validation, anat_only):

    preprocess(
        bids_dir=Path(),
        output_dir=Path(),
        action=action,
        verbosity=2,
        participant_label=["01"],
        fwhm=6,
        dummy_scans=1,
        space=["MNI"],
        task=["rest"],
        ignore=["slice-timing"],
        anat_only=anat_only,
        skip_validation=skip_validation,
        bids_filter_file=None,
        dry_run=dry_run,
    )


@pytest.mark.parametrize("analysis_level", ["subject", "dataset"])
@pytest.mark.parametrize(
    "action",
    [
        "stats",
        "contrasts",
        "results",
    ],
)
@pytest.mark.parametrize("roi_based", [True, False])
@pytest.mark.parametrize("concatenate", [True, False])
@pytest.mark.parametrize("design_only", [True, False])
@pytest.mark.parametrize("keep_residuals", [True, False])
@pytest.mark.parametrize("dry_run", [True, False])
@pytest.mark.parametrize("skip_validation", [True, False])
def test_stats(
    analysis_level,
    action,
    roi_based,
    dry_run,
    keep_residuals,
    skip_validation,
    design_only,
    concatenate,
):

    cmd = stats(
        bids_dir=Path(),
        output_dir=Path(),
        preproc_dir=Path(),
        analysis_level=analysis_level,
        model_file=Path(),
        action=action,
        verbosity=2,
        participant_label=["01"],
        fwhm=6,
        skip_validation=skip_validation,
        bids_filter_file=None,
        dry_run=dry_run,
        roi_based=roi_based,
        keep_residuals=keep_residuals,
        design_only=design_only,
        concatenate=concatenate,
    )
    assert analysis_level in cmd


@pytest.mark.parametrize("analysis_level", ["subject", "dataset"])
def test_defautl_model(analysis_level):
    default_model(
        bids_dir=Path(),
        output_dir=Path(),
        analysis_level=analysis_level,
        verbosity=2,
        space=["MNI"],
        task=["rest"],
        ignore=["foo"],
    )


def test_create_roi():
    create_roi(
        bids_dir=Path(),
        output_dir=Path(),
        preproc_dir=Path(),
        verbosity=2,
        participant_label=["01"],
        roi_dir=Path(),
        roi_atlas="neuromorphometrics",
        roi_name=["foo", "bar"],
        space=["MNI"],
        bids_filter_file=None,
    )
