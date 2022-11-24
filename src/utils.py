from pathlib import Path


def root_dir() -> Path:
    return Path(__file__).parent.parent.resolve()
