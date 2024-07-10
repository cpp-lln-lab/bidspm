from bidspm.parsers import common_parser


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
