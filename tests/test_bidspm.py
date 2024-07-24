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
    generate_command_bms,
    generate_command_contrasts,
    generate_command_create_roi,
    generate_command_default_model,
    generate_command_preprocess,
    generate_command_results,
    generate_command_smooth,
    generate_command_stats,
    new_line,
    preprocess,
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
    """Test generate_command_default_model."""
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

    assert "fwhm" not in cmd

    print()
    print(cmd)


def test_generate_command_default_model_minimal():
    """Test generate_command_default_model with only required arguments."""
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
    """Test generate_command_create_roi."""
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
    """Test generate_command_create_roi with only required arguments."""
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


def test_generate_command_smooth():
    """Test generate_command_smooth."""
    cmd = generate_command_smooth(
        [
            "bidspm",
            str(Path().absolute()),
            str(Path().absolute()),
            "subject",
            "smooth",
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
            "--anat_only",
            "--dry_run",
        ]
    )

    print()
    print(cmd)


def test_generate_command_smooth_minimal():
    """Testgenerate_command_smooth with only required arguments."""
    cmd = generate_command_smooth(
        [
            "bidspm",
            str(Path().absolute()),
            str(Path().absolute()),
            "subject",
            "smooth",
        ]
    )

    print()
    print(cmd)


def test_generate_command_preprocess():
    """Test generate_command_preprocess."""
    cmd = generate_command_preprocess(
        [
            "bidspm",
            str(Path().absolute()),
            str(Path().absolute()),
            "subject",
            "preprocess",
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
            "--fwhm",
            "8",
            "--dry_run",
            "--anat_only",
            "--skip_validation",
            "--boilerplate_only",
            "--dummy_scans",
            "0",
            "--ignore",
            "slicetiming",
            "unwarp",
        ]
    )

    assert "boilerplate_only" in cmd
    assert "ignore" in cmd
    assert "dummy_scans" in cmd

    print()
    print(cmd)


def test_generate_command_preprocess_minimal():
    """Test generate_command_preprocess with only required arguments."""
    cmd = generate_command_preprocess(
        [
            "bidspm",
            str(Path().absolute()),
            str(Path().absolute()),
            "subject",
            "preprocess",
        ]
    )

    print()
    print(cmd)


def test_generate_command_stats():
    """Test generate_command_stats."""
    cmd = generate_command_stats(
        [
            "bidspm",
            str(Path().absolute()),
            str(Path().absolute()),
            "subject",
            "stats",
            "--participant_label",
            "01",
            "02",
            "--verbosity",
            "3",
            "--bids_filter_file",
            str((Path() / "filter.json").absolute()),
            "--options",
            str((Path() / "options.json").absolute()),
            "--model_file",
            str((Path() / "model.json").absolute()),
            "--preproc_dir",
            str(Path().absolute()),
            "--boilerplate_only",
            "--space",
            "IXI549Space",
            "--task",
            "rest",
            "--fwhm",
            "0",
            "--dry_run",
            "--skip_validation",
            "--concatenate",
            "--design_only",
            "--keep_residuals",
            "--use_dummy_regressor",
            "--roi_based",
            "--roi_dir",
            "path_to_rois",
            "--roi_name",
            "V1",
            "V3",
            "--ignore",
            "qa",
            "--roi_atlas",
            "wang",
        ]
    )

    print()
    print(cmd)

    assert "design_only" in cmd
    assert "ignore" in cmd
    assert "roi_atlas" in cmd
    assert "roi_name" in cmd
    assert "use_dummy_regressor" in cmd
    assert "keep_residuals" in cmd
    assert "concatenate" in cmd
    assert "fwhm" in cmd


def test_generate_command_stats_minimal():
    """Test generate_command_stats with only required arguments."""
    cmd = generate_command_stats(
        [
            "bidspm",
            str(Path().absolute()),
            str(Path().absolute()),
            "subject",
            "stats",
            "--model_file",
            str((Path() / "model.json").absolute()),
            "--preproc_dir",
            str(Path().absolute()),
        ]
    )

    print()
    print(cmd)


def test_generate_command_contrasts():
    """Test generate_command_contrasts."""
    cmd = generate_command_contrasts(
        [
            "bidspm",
            str(Path().absolute()),
            str(Path().absolute()),
            "subject",
            "contrasts",
            "--participant_label",
            "01",
            "02",
            "--verbosity",
            "3",
            "--bids_filter_file",
            str((Path() / "filter.json").absolute()),
            "--options",
            str((Path() / "options.json").absolute()),
            "--model_file",
            str((Path() / "model.json").absolute()),
            "--preproc_dir",
            str(Path().absolute()),
            "--boilerplate_only",
            "--space",
            "IXI549Space",
            "--task",
            "rest",
            "--fwhm",
            "8",
            "--dry_run",
            "--skip_validation",
            "--concatenate",
        ]
    )

    print()
    print(cmd)


def test_generate_command_contrasts_minimal():
    """Test generate_command_contrasts with only required arguments."""
    cmd = generate_command_contrasts(
        [
            "bidspm",
            str(Path().absolute()),
            str(Path().absolute()),
            "subject",
            "contrasts",
            "--model_file",
            str((Path() / "model.json").absolute()),
        ]
    )

    print()
    print(cmd)


def test_generate_command_results():
    """Test generate_command_results."""
    cmd = generate_command_results(
        [
            "bidspm",
            str(Path().absolute()),
            str(Path().absolute()),
            "subject",
            "results",
            "--participant_label",
            "01",
            "02",
            "--verbosity",
            "3",
            "--bids_filter_file",
            str((Path() / "filter.json").absolute()),
            "--options",
            str((Path() / "options.json").absolute()),
            "--model_file",
            str((Path() / "model.json").absolute()),
            "--preproc_dir",
            str(Path().absolute()),
            "--boilerplate_only",
            "--space",
            "IXI549Space",
            "--task",
            "rest",
            "--fwhm",
            "8",
            "--dry_run",
            "--skip_validation",
            "--roi_atlas",
            "wang",
        ]
    )

    print()
    print(cmd)

    assert "roi_atlas" in cmd


def test_generate_command_results_minimal():
    """Test generate_command_results with only required arguments."""
    cmd = generate_command_results(
        [
            "bidspm",
            str(Path().absolute()),
            str(Path().absolute()),
            "subject",
            "results",
            "--model_file",
            str((Path() / "model.json").absolute()),
        ]
    )

    print()
    print(cmd)


def test_generate_command_bms():
    """Test generate_command_results with only required arguments."""
    cmd = generate_command_bms(
        [
            "bidspm",
            str(Path().absolute()),
            str(Path().absolute()),
            "subject",
            "bms",
            "--participant_label",
            "01",
            "02",
            "--verbosity",
            "3",
            "--bids_filter_file",
            str((Path() / "filter.json").absolute()),
            "--options",
            str((Path() / "options.json").absolute()),
            "--models_dir",
            str(Path().absolute()),
            "--fwhm",
            "9",
            "--dry_run",
            "--skip_validation",
        ]
    )

    print()
    print(cmd)
