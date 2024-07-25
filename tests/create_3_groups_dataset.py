from __future__ import annotations

import shutil
from pathlib import Path

import pandas as pd

from utils import (
    create_preproc_func_vismotion,
    create_raw_func_vismotion,
    touch,
    write_ds_desc,
)

ROOT_DIR = Path(__file__).parent.parent
START_DIR = Path(__file__).parent
SUBJECTS = ["ctrl01", "blind01", "relative01", "ctrl02", "blind02", "relative02"]
# SUBJECTS = ["ctrl01", "blind01", "relative01"]
SESSIONS = ["01", "02"]
SESSIONS = ["01"]


def main(start_dir, subject_list, session_list):
    # Create BIDS directory structure
    raw_dir = start_dir / "data" / "3_groups" / "bidspm-raw"
    write_ds_desc(raw_dir)
    derivative_dir = start_dir / "data" / "3_groups" / "derivatives"
    preproc_dir = derivative_dir / "bidspm-preproc"
    write_ds_desc(preproc_dir)
    stats_dir = derivative_dir / "bidspm-stats"
    write_ds_desc(stats_dir)

    create_raw_dataset(raw_dir, subject_list, session_list)
    create_preproc_dataset(preproc_dir, subject_list, session_list)
    create_stats_dataset(stats_dir, subject_list)


def create_raw_dataset(target_dir, subject_list, session_list):
    # Create the raw BIDS dataset
    create_participants_tsv(target_dir, subject_list)
    for sub in subject_list:
        for ses in session_list:
            create_raw_func_vismotion(target_dir, sub, ses)


def create_preproc_dataset(target_dir, subject_list, session_list):
    for sub in subject_list:
        for ses in session_list:
            create_preproc_func_vismotion(target_dir, sub, ses)


def create_participants_tsv(bids_dir, subject_list):
    bids_dir.parent.mkdir(parents=True, exist_ok=True)
    content = {
        "participant_id": subject_list,
        "diagnostic": [x[:-2] for x in subject_list],
    }
    df = pd.DataFrame(content)
    df.to_csv(bids_dir / "participants.tsv", sep="\t", index=False)


def create_stats_dataset(stats_dir, subject_list):
    task_list = ["vismotion"]

    for sub in subject_list:
        for task in task_list:
            this_dir = stats_dir / f"sub-{sub}" / f"task-{task}_space-IXI549Space_FWHM-6"

            touch(this_dir / "mask.nii")

            for i in range(1, 10):
                touch(this_dir / f"beta_000{i}.nii")

            for i in range(1, 5):
                touch(this_dir / f"spmT_000{i}.nii")
                touch(this_dir / f"con_000{i}.nii")

            shutil.copy(
                ROOT_DIR / "tests" / "data" / "mat_files" / "SPM.mat",
                this_dir / "SPM.mat",
            )


if __name__ == "__main__":
    main(
        start_dir=START_DIR,
        subject_list=SUBJECTS,
        session_list=SESSIONS,
    )
