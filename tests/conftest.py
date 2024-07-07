from pathlib import Path

import pytest


@pytest.fixture
def root_dir():
    return Path(__file__).parents[1]


@pytest.fixture
def data_dir():
    return Path(__file__).parent / "data"
