# mypy: ignore-errors
from __future__ import annotations

from pathlib import Path

from src.bidspm import append_base_arguments
from src.bidspm import base_cmd
from src.parsers import common_parser


def test_base_cmd():
    """Test base_cmd."""
    bids_dir = Path("/path/to/bids")
    output_dir = Path("/path/to/output")
    cmd = base_cmd(bids_dir, output_dir)
    assert cmd == " bidspm(); bidspm('/path/to/bids', ...\n\t '/path/to/output'"


def test_parser():
    """Test parser."""
    parser = common_parser()
    assert parser.description == "bidspm is a SPM base BIDS app"

    args, unknowns = parser.parse_known_args(
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


def test_append_base_arguments():

    cmd = append_base_arguments(
        cmd="", verbosity=0, space=["foo", "bar"], task=["spam", "eggs"], ignore=["nii"]
    )
    assert (
        cmd
        == ", ...\n\t 'verbosity', 0, ...\n\t 'space', { 'foo', 'bar' }, ...\n\t 'task', { 'spam', 'eggs' }, ...\n\t 'ignore', { 'nii' }"
    )
