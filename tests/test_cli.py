from pathlib import Path

import pytest

from bidspm.cli import _run_command, cli


def test_bidspm_error_dir(caplog):

    with pytest.raises(SystemExit) as pytest_wrapped_e:
        cli(["bidspm", "/foo/bar", str(Path()), "subject", "preprocess"])

    assert pytest_wrapped_e.type == SystemExit
    assert pytest_wrapped_e.value.code == 66
    assert ["The 'bids_dir' does not exist:\n\t/foo/bar"] == [
        rec.message for rec in caplog.records
    ]


def test_run_command():
    """Test run_command."""
    cmd = "disp('hello'); exit();"
    return_code = _run_command(cmd, platform="octave")
    assert return_code == 0
