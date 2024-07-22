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


@pytest.mark.parametrize("action", ["bms"])
def test_bms(action):
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
        ]
    )

    assert args.participant_label == ["01", "02"]


@pytest.mark.parametrize("action", ["preprocess"])
def test_preprocess(action):
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
        ]
    )

    assert args.participant_label == ["01", "02"]
