# mypy: ignore-errors
from __future__ import annotations

from pathlib import Path

import pytest
from rich import print

from bidspm.bidspm import (
    append_base_arguments,
    append_common_arguments,
    base_cmd,
    create_roi,
    default_model,
    generate_command_create_roi,
    generate_command_default_model,
    new_line,
    preprocess,
    run_command,
    stats,
)


def test_base_cmd():
    """Test base_cmd."""
    bids_dir = Path("/path/to/bids")
    output_dir = Path("/path/to/output")
    cmd = base_cmd(bids_dir, output_dir)
    assert cmd == f" bidspm( '/path/to/bids'{new_line}'/path/to/output'"


def test_append_common_arguments():
    cmd = append_common_arguments(
        cmd="",
        fwhm=6,
        participant_label=["01", "02"],
        skip_validation=True,
        dry_run=True,
    )
    assert cmd == (
        f"{new_line}'fwhm', 6{new_line}'participant_label', {'{'} '01', '02' {'}'}"
        f"{new_line}'skip_validation', true{new_line}'dry_run', true"
    )


def test_append_base_arguments():
    cmd = append_base_arguments(
        cmd="", verbosity=0, space=["foo", "bar"], task=["spam", "eggs"], ignore=["nii"]
    )
    assert cmd == (
        f"{new_line}'verbosity', 0{new_line}'space', {'{'} 'foo', 'bar' {'}'}"
        f"{new_line}'task', {'{'} 'spam', 'eggs' {'}'}{new_line}'ignore', {'{'} 'nii' {'}'}"
    )


def test_run_command():
    """Test run_command."""
    cmd = "disp('hello'); exit();"
    return_code = run_command(cmd, platform="octave")
    assert return_code == 0


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


def test_options():
    cmd = preprocess(
        bids_dir=Path(),
        output_dir=Path(),
        action="preprocess",
        participant_label=["01"],
        space=["MNI"],
        task=["rest"],
        options=Path() / "foo.json",
    )
    assert "'options', 'foo.json'" in cmd

    cmd = stats(
        bids_dir=Path(),
        output_dir=Path(),
        preproc_dir=Path(),
        analysis_level="subject",
        model_file=Path(),
        action="stats",
        participant_label=["01"],
        options=Path() / "foo.json",
    )
    assert "'options', 'foo.json'" in cmd


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


@pytest.mark.parametrize("analysis_level", ["subject", "dataset"])
def test_generate_command_default_model(analysis_level):
    """Test default_model sub commands parser."""
    cmd = generate_command_default_model(
        [
            "bidspm",
            str(Path().absolute()),
            str(Path().absolute()),
            analysis_level,
            "default_model",
            "--participant_label",
            "01",
            "02",
            "--verbosity",
            "3",
            "--bids_filter_file",
            str((Path() / "filter.json").absolute()),
            "--options",
            str((Path() / "options.json").absolute()),
            "--space",
            "IXI549Space",
            "--task",
            "rest",
            "--ignore",
            "Transformations",
            "Contrasts",
            "Dataset",
            "--skip_validation",
        ]
    )

    print()
    print(cmd)


def test_generate_command_default_model_minimal():
    """Test default_model sub commands parser."""
    cmd = generate_command_default_model(
        [
            "bidspm",
            str(Path().absolute()),
            str(Path().absolute()),
            "subject",
            "default_model",
        ]
    )

    print()
    print(cmd)


@pytest.mark.parametrize("analysis_level", ["subject", "dataset"])
def test_generate_command_create_roi(analysis_level):
    """Test default_model sub commands parser."""
    cmd = generate_command_create_roi(
        [
            "bidspm",
            str(Path().absolute()),
            str(Path().absolute()),
            analysis_level,
            "create_roi",
            "--participant_label",
            "01",
            "02",
            "--verbosity",
            "3",
            "--bids_filter_file",
            str((Path() / "filter.json").absolute()),
            "--options",
            str((Path() / "options.json").absolute()),
            "--space",
            "IXI549Space",
            "--boilerplate_only",
            "--roi_dir",
            str(Path().absolute()),
            "--preproc_dir",
            str(Path().absolute()),
            "--hemisphere",
            "L",
            "--roi_atlas",
            "neuromorphometrics",
            "--roi_name",
            "V1",
            "V2",
        ]
    )

    print()
    print(cmd)


def test_generate_command_create_roi_minimal():
    """Test default_model sub commands parser."""
    cmd = generate_command_create_roi(
        [
            "bidspm",
            str(Path().absolute()),
            str(Path().absolute()),
            "subject",
            "create_roi",
            "--roi_name",
            "V1",
        ]
    )

    print()
    print(cmd)
