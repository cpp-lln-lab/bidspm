import pytest

from bidspm.validate import main


def test_main_missing(data_dir):
    with pytest.raises(FileNotFoundError):
        main(data_dir / "models" / "foo.json")


def test_main_file(data_dir):
    main(data_dir / "models" / "model-bug385_smdl.json")


def test_main_folder(root_dir):
    main(root_dir / "demos" / "MoAE" / "models")
