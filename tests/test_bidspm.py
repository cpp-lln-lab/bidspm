# mypy: ignore-errors
from __future__ import annotations

from pathlib import Path

import pytest

from src.bidspm import (
    append_base_arguments,
    append_common_arguments,
    base_cmd,
    bidspm,
    run_command,
)
from src.parsers import common_parser


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
