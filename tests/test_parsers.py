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
