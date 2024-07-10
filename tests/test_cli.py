from pathlib import Path

import pytest

from bidspm.cli import cli


def test_bidspm_error_dir(caplog):

    with pytest.raises(SystemExit) as pytest_wrapped_e:
        cli(["bidspm", "/foo/bar", str(Path()), "subject", "--action", "preprocess"])

    assert pytest_wrapped_e.type == SystemExit
    assert pytest_wrapped_e.value.code == 66
    assert ["The 'bids_dir' does not exist:\n\t/foo/bar"] == [
        rec.message for rec in caplog.records
    ]


def test_bidspm_error_action(caplog):
    with pytest.raises(SystemExit) as pytest_wrapped_e:
        cli(["bidspm", str(Path()), str(Path()), "subject", "--action", "bms"])

    assert pytest_wrapped_e.type == SystemExit
    assert pytest_wrapped_e.value.code == 64
    assert any("not yet implemented" in rec.message for rec in caplog.records)
