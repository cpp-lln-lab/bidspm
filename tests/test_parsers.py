import pytest

from bidspm.parsers import sub_command_parser


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


@pytest.mark.parametrize("action", ["stats", "contrasts", "results"])
def test_all_stats_actions(action):
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
            "--space",
            "IXI549Space",
            "--task",
            "rest",
            "--fwhm",
            "8",
            "--dry_run",
            "--skip_validation",
        ]
    )
    assert args.participant_label == ["01", "02"]


def test_stats_action():
    """Test sub commands parser."""
    parser = sub_command_parser()
    assert parser.description == "bidspm is a SPM base BIDS app"

    args = parser.parse_args(
        [
            "/path/to/bids",
            "/path/to/output",
            "subject",
            "stats",
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
            "--space",
            "IXI549Space",
            "--task",
            "rest",
            "--fwhm",
            "8",
            "--dry_run",
            "--skip_validation",
            "--design_only",
            "--use_dummy_regressor",
            "--roi_based",
            "--roi_dir",
            "path_to_rois",
            "--roi_name",
            "V1",
            "V3",
            "--ignore",
            "qa",
        ]
    )

    assert args.participant_label == ["01", "02"]
