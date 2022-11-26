from pathlib import Path

from src.bidspm import append_base_arguments
from src.bidspm import append_common_arguments
from src.bidspm import base_cmd


def test_base_cmd():
    """Test base_cmd."""
    bids_dir = Path("/path/to/bids")
    output_dir = Path("/path/to/output")
    cmd = base_cmd(bids_dir, output_dir)
    assert cmd == " bidspm(); bidspm('/path/to/bids', ...\n\t '/path/to/output'"
