import pytest

from bidspm.parsers import common_parser, sub_command_parser


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


def test_bms():
    """Test sub commands parser."""
    parser = sub_command_parser()
    assert parser.description == "bidspm is a SPM base BIDS app"

    args = parser.parse_args(
        [
            "/path/to/bids",
            "/path/to/output",
            "subject",
            "bms",
            "--participant_label",
            "01",
            "02",
            "--verbosity",
            "3",
            "--bids_filter_file",
            "path_to_filter",
            "--options",
            "path_options",
            "--models_dir",
            "path_models_dir",
            "--fwhm",
            "9",
            "--dry_run",
            "--skip_validation",
        ]
    )

    assert args.participant_label == ["01", "02"]


def test_create_roi():
    """Test create_roi sub commands parser."""
    parser = sub_command_parser()
    assert parser.description == "bidspm is a SPM base BIDS app"

    args = parser.parse_args(
        [
            "/path/to/bids",
            "/path/to/output",
            "subject",
            "create_roi",
            "--participant_label",
            "01",
            "02",
            "--verbosity",
            "3",
            "--bids_filter_file",
            "path_to_filter",
            "--options",
            "path_options",
            "--space",
            "IXI549Space",
            "--boilerplate_only",
            "--roi_dir",
            "path_to_roi_dir",
            "--preproc_dir",
            "path_to_preproc_dir",
            "--hemisphere",
            "L",
            "--roi_atlas",
            "neuromorphometrics",
            "--roi_name",
            "V1",
            "V2",
        ]
    )

    assert args.participant_label == ["01", "02"]


def test_default_model():
    """Test default_model sub commands parser."""
    parser = sub_command_parser()
    assert parser.description == "bidspm is a SPM base BIDS app"

    args = parser.parse_args(
        [
            "/path/to/bids",
            "/path/to/output",
            "subject",
            "default_model",
            "--participant_label",
            "01",
            "02",
            "--verbosity",
            "3",
            "--bids_filter_file",
            "path_to_filter",
            "--options",
            "path_options",
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

    assert args.participant_label == ["01", "02"]


def test_preprocess():
    """Test sub commands parser."""
    parser = sub_command_parser()
    assert parser.description == "bidspm is a SPM base BIDS app"

    args = parser.parse_args(
        [
            "/path/to/bids",
            "/path/to/output",
            "subject",
            "preprocess",
            "--participant_label",
            "01",
            "02",
            "--verbosity",
            "3",
            "--bids_filter_file",
            "path_to_filter",
            "--options",
            "path_options",
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
            "3",
            "--ignore",
            "slicetiming",
            "unwarp",
        ]
    )

    assert args.participant_label == ["01", "02"]


@pytest.mark.parametrize("action", ["contrasts", "results", "stats"])
def test_stats(action):
    """Test sub commands parser."""
    parser = sub_command_parser()
    assert parser.description == "bidspm is a SPM base BIDS app"

    args = parser.parse_args(
        [
            "/path/to/bids",
            "/path/to/output",
            "subject",
            action,
            "--participant_label",
            "01",
            "02",
            "--verbosity",
            "3",
            "--bids_filter_file",
            "path_to_filter",
            "--options",
            "path_options",
            "--model_file",
            "path_to_model",
            "--preproc_dir",
            "path_to_preproc",
            "--boilerplate_only",
        ]
    )

    assert args.participant_label == ["01", "02"]
