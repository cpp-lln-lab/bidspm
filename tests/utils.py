import json
import shutil
from pathlib import Path

import pandas as pd

ROOT_DIR = Path(__file__).parent.parent


def touch(path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "a"):
        pass


def write_ds_desc(bids_dir: Path, DatasetType="raw"):
    content = {
        "BIDSVersion": "1.9.0",
        "DatasetType": DatasetType,
        "Name": f"bidspm {DatasetType}",
    }
    bids_dir.mkdir(parents=True, exist_ok=True)
    with open(bids_dir / "dataset_description.json", "w") as f:
        json.dump(content, f, indent=4)


def create_events_tsv(filename, onset, duration, trial_type):
    filename.parent.mkdir(parents=True, exist_ok=True)
    events = {
        "onset": onset,
        "duration": duration,
        "trial_type": trial_type,
    }
    df = pd.DataFrame(events)
    df.to_csv(filename, sep="\t", index=False)


def create_raw_func_vismotion(target_dir, sub, ses):
    suffix = "bold"
    task = "vismotion"
    this_dir = target_dir / f"sub-{sub}" / f"ses-{ses}" / "func"

    basename = f"sub-{sub}_ses-{ses}_task-{task}"

    create_events_tsv(
        filename=this_dir / f"{basename}_run-1_events.tsv",
        onset=[2, 4],
        duration=[2, 2],
        trial_type=["VisMot", "VisStat"],
    )

    for run in range(1, 3):
        filename = this_dir / f"{basename}_run-{run}_part-mag_{suffix}.nii"
        touch(filename)
        filename = this_dir / f"{basename}_run-{run}_part-phase_{suffix}.nii"
        touch(filename)

    create_events_tsv(
        filename=this_dir / f"{basename}_run-2_events.tsv",
        onset=[3, 6],
        duration=[2, 2],
        trial_type=["VisStat", "VisMot"],
    )

    touch(this_dir / f"{basename}_acq-1p60mm_run-1_{suffix}.nii")

    for run in [1, 2]:
        create_events_tsv(
            filename=this_dir / f"{basename}_acq-1p60mm_run-{run}_events.tsv",
            onset=[4, 8],
            duration=[2, 2],
            trial_type=["VisMot", "VisStat"],
        )
        touch(this_dir / f"{basename}_acq-1p60mm_dir-PA_run-{run}_{suffix}.nii")


def create_preproc_func_vismotion(target_dir, sub, ses):
    suffix = "bold"
    task = "vismotion"
    this_dir = target_dir / f"sub-{sub}" / f"ses-{ses}" / "func"

    for acq_entity in ["", "_acq-1p60mm"]:
        basename = f"sub-{sub}_ses-{ses}_task-{task}{acq_entity}_part-mag"

        if ses == "01":
            touch(this_dir / f"{basename}_space-individual_desc-mean_{suffix}.nii")
            touch(this_dir / f"{basename}_space-IXI549Space_desc-mean_{suffix}.nii")
            touch(this_dir / f"mean_{basename}_{suffix}.nii")

        for run in range(1, 3):
            basename = f"sub-{sub}_ses-{ses}_task-{task}{acq_entity}_run-{run}_part-mag"

            desc_label_list = ["preproc", "mean", "smth6"]
            for desc in desc_label_list:
                touch(this_dir / f"{basename}_space-individual_desc-{desc}_{suffix}.nii")
                touch(this_dir / f"{basename}_space-IXI549Space_desc-{desc}_{suffix}.nii")

            touch(this_dir / f"{basename}_space-individual_desc-stc_{suffix}.nii")
            touch(this_dir / f"{basename}_space-IXI549Space_desc-brain_mask.nii")

            filename = this_dir / f"rp_{basename}_{suffix}.txt"
            shutil.copy(ROOT_DIR / "tests" / "data" / "tsv_files" / "rp.txt", filename)

            shutil.copy(
                ROOT_DIR / "tests" / "data" / "tsv_files" / "rp.tsv",
                this_dir / f"{basename}_desc-confounds_regressors.tsv",
            )
