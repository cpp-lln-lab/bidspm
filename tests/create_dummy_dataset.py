from __future__ import annotations

import json
import shutil
from pathlib import Path

from utils import (
    ROOT_DIR,
    create_events_tsv,
    create_preproc_func_vismotion,
    create_raw_func_vismotion,
    touch,
    write_ds_desc,
)

START_DIR = Path(__file__).parent
SUBJECTS = ["ctrl01", "blind01", "01"]
SESSIONS = ["01", "02"]
ROIS = ["V1", "A1"]
HEMISPHERES = ["L", "R"]


def main(start_dir, subject_list, session_list, roi_list, hemispheres):
    # Create BIDS directory structure
    raw_dir = start_dir / "data" / "bidspm-raw"
    write_ds_desc(start_dir / "data" / "bidspm-raw")
    derivative_dir = start_dir / "data" / "derivatives"
    preproc_dir = derivative_dir / "bidspm-preproc"
    stats_dir = derivative_dir / "bidspm-stats"
    roi_dir = derivative_dir / "bidspm-roi"

    create_raw_dataset(raw_dir, subject_list, session_list)
    create_preproc_dataset(preproc_dir, subject_list, session_list)
    create_roi_directories(roi_dir, roi_list, subject_list, hemispheres)

    create_stats_dataset(stats_dir, subject_list)


def create_raw_dataset(target_dir, subject_list, session_list):
    # Create the raw BIDS dataset
    for sub in subject_list:
        for ses in session_list:
            create_raw_func_vismotion(target_dir, sub, ses)
            create_raw_func_vislocalizer(target_dir, sub, ses)
            create_raw_fmap(target_dir, sub, ses)

        create_raw_func_rest(target_dir, sub, "02")
        create_raw_anat(target_dir, sub)


def create_raw_func_vislocalizer(target_dir, sub, ses):
    suffix = "bold"
    task = "vislocalizer"
    this_dir = target_dir / f"sub-{sub}" / f"ses-{ses}" / "func"

    basename = f"sub-{sub}_ses-{ses}_task-{task}"
    touch(this_dir / f"{basename}_part-mag_{suffix}.nii")
    touch(this_dir / f"{basename}_part-phase_{suffix}.nii")

    create_events_tsv(
        filename=this_dir / f"{basename}_events.tsv",
        onset=[2, 25],
        duration=[15, 15],
        trial_type=["VisMot", "VisStat"],
    )


def create_raw_func_rest(target_dir, sub, ses):
    suffix = "bold"
    task = "rest"
    this_dir = target_dir / f"sub-{sub}" / f"ses-{ses}" / "func"

    touch(this_dir / f"sub-{sub}_ses-{ses}_task-{task}_{suffix}.nii")


def create_raw_fmap(target_dir, sub, ses):
    this_dir = target_dir / f"sub-{sub}" / f"ses-{ses}" / "fmap"

    fmap_suffix_list = ["phasediff", "magnitude1", "magnitude2"]
    for suffix in fmap_suffix_list:
        touch(this_dir / f"sub-{sub}_ses-{ses}_run-1_{suffix}.nii")
        touch(this_dir / f"sub-{sub}_ses-{ses}_run-2_{suffix}.nii")

    suffix = "bold"
    task = "vislocalizer"

    content = {
        "EchoTime1": 0.006,
        "EchoTime2": 0.00746,
        "IntendedFor": f"ses-{ses}/func/sub-{sub}_ses-{ses}_task-{task}_part-mag_{suffix}.nii",
    }

    with open(this_dir / f"sub-{sub}_ses-{ses}_run-1_phasediff.json", "w") as f:
        json.dump(content, f, indent=4)

    task = "vismotion"
    content["IntendedFor"] = (
        f"ses-{ses}/func/sub-{sub}_ses-{ses}_task-{task}_run-1_part-mag_{suffix}.nii"
    )
    with open(this_dir / f"sub-{sub}_ses-{ses}_run-2_phasediff.json", "w") as f:
        json.dump(content, f, indent=4)


def create_raw_anat(target_dir, sub):
    ses = "01"
    suffix = "T1w"
    this_dir = target_dir / f"sub-{sub}" / f"ses-{ses}" / "anat"

    touch(this_dir / f"sub-{sub}_ses-{ses}_{suffix}.nii")

    # MP2RAGE
    touch(this_dir / f"sub-{sub}_ses-{ses}_UNIT1.nii")
    touch(this_dir / f"sub-{sub}_ses-{ses}_inv-1_MP2RAGE.nii")
    touch(this_dir / f"sub-{sub}_ses-{ses}_inv-2_MP2RAGE.nii")

    content = {
        "MagneticFieldStrength": 7,
        "RepetitionTimePreparation": 4.3,
        "InversionTime": 1,
        "FlipAngle": 4,
        "FatSat": "yes",
        "EchoSpacing": 0.0072,
        "PartialFourierInSlice": 0.75,
    }

    with open(this_dir / f"sub-{sub}_ses-{ses}_inv-1_MP2RAGE.json", "w") as f:
        json.dump(content, f, indent=4)

    content["InversionTime"] = 3.2
    with open(this_dir / f"sub-{sub}_ses-{ses}_inv-2_MP2RAGE.json", "w") as f:
        json.dump(content, f, indent=4)


def create_preproc_dataset(target_dir, subject_list, session_list):
    # Create the derivatives BIDS dataset
    create_raw_dataset(target_dir, subject_list, session_list)

    for sub in subject_list:
        for ses in session_list:
            create_preproc_func_vismotion(target_dir, sub, ses)
            create_preproc_func_vislocalizer(target_dir, sub, ses)
        create_preproc_func_rest(target_dir, sub, "02")
        create_preproc_anat(target_dir, sub)


def create_preproc_func_vislocalizer(target_dir, sub, ses):
    suffix = "bold"
    task = "vislocalizer"
    this_dir = target_dir / f"sub-{sub}" / f"ses-{ses}" / "func"
    this_dir.mkdir(parents=True, exist_ok=True)

    basename = f"sub-{sub}_ses-{ses}_task-{task}"

    filename = this_dir / f"rp_{basename}_{suffix}.txt"
    shutil.copy(ROOT_DIR / "tests" / "data" / "tsv_files" / "rp.txt", filename)
    shutil.copy(
        ROOT_DIR / "tests" / "data" / "tsv_files" / "rp.tsv",
        this_dir / f"{basename}_part-mag_desc-confounds_regressors.tsv",
    )

    basename += "_part-mag"

    desc_label_list = ["preproc", "smth6"]
    for desc in desc_label_list:
        touch(this_dir / f"{basename}_space-individual_desc-{desc}_{suffix}.nii")
        touch(this_dir / f"{basename}_space-IXI549Space_desc-{desc}_{suffix}.nii")
        touch(this_dir / f"{basename}_space-IXI549Space_desc-brain_mask.nii")

    if ses == "01":
        touch(this_dir / f"{basename}_space-individual_desc-mean_{suffix}.nii")
        touch(this_dir / f"{basename}_space-IXI549Space_desc-mean_{suffix}.nii")

    touch(this_dir / f"mean_{basename}_{suffix}.nii")


def create_preproc_func_rest(target_dir, sub, ses):
    task = "rest"
    this_dir = target_dir / f"sub-{sub}" / f"ses-{ses}" / "func"

    basename = f"sub-{sub}_ses-{ses}_task-{task}"

    for space in ["individual", "IXI549Space"]:
        touch(this_dir / f"{basename}_space-{space}_desc-preproc_bold.nii")
        touch(this_dir / f"{basename}_space-{space}_desc-brain_mask.nii")

    shutil.copy(
        ROOT_DIR / "tests" / "data" / "tsv_files" / "rp.tsv",
        this_dir / f"{basename}_part-mag_desc-confounds_regressors.tsv",
    )


def create_preproc_anat(target_dir, sub):
    ses = "01"
    suffix = "T1w"

    this_dir = target_dir / f"sub-{sub}" / f"ses-{ses}" / "anat"

    basename = f"sub-{sub}_ses-{ses}"

    touch(this_dir / f"{basename}_{suffix}.nii")

    anat_prefix_list = ["m", "c1", "c2", "c3"]
    for prefix in anat_prefix_list:
        touch(this_dir / f"{prefix}{basename}_{suffix}.nii")

    for space in ["individual", "IXI549Space"]:
        touch(this_dir / f"{basename}_space-{space}_desc-brain_mask.nii")
        for label in ["CSF", "GM", "WM"]:
            res_entity = ""
            if space == "IXI549Space":
                res_entity = "_res-bold"
            touch(
                this_dir
                / f"{basename}_space-{space}{res_entity}_label-{label}_probseg.nii"
            )

    touch(this_dir / f"{basename}_space-individual_desc-biascor_{suffix}.nii")
    touch(this_dir / f"{basename}_space-individual_desc-skullstripped_{suffix}.nii")
    touch(this_dir / f"{basename}_space-individual_desc-preproc_{suffix}.nii")

    touch(this_dir / f"{basename}_space-IXI549Space_res-hi_desc-preproc_{suffix}.nii")
    touch(this_dir / f"{basename}_from-IXI549Space_to-T1w_mode-image_xfm.nii")


def create_stats_dataset(stats_dir, subject_list):
    task_list = ["vismotion", "vislocalizer"]

    for sub in subject_list:
        for task in task_list:
            this_dir = stats_dir / f"sub-{sub}" / f"task-{task}_space-IXI549Space_FWHM-6"

            touch(this_dir / "mask.nii")

            shutil.copy(
                ROOT_DIR / "tests" / "data" / "mat_files" / "SPM.mat",
                this_dir / "SPM.mat",
            )

            for i in range(1, 10):
                touch(this_dir / f"beta_000{i}.nii")

            for i in range(1, 5):
                touch(this_dir / f"spmT_000{i}.nii")
                touch(this_dir / f"con_000{i}.nii")
                touch(this_dir / f"s6con_000{i}.nii")

        # Different model for model comparison
        for task in task_list:
            this_dir = (
                stats_dir
                / f"sub-{sub}"
                / f"task-{task}_space-IXI549Space_FWHM-6_node-globalSignal"
            )

            touch(this_dir / "mask.nii")

            shutil.copy(
                ROOT_DIR / "tests" / "data" / "mat_files" / "SPM.mat",
                this_dir / "SPM.mat",
            )

            for i in range(1, 11):
                touch(this_dir / f"beta_000{i}.nii")

            for i in range(1, 3):
                touch(this_dir / f"spmT_000{i}.nii")
                touch(this_dir / f"con_000{i}.nii")


def create_roi_directories(roi_dir, roi_list, subject_list, hemispheres):
    # Create ROI directories
    roi_group_dir = roi_dir / "group"

    for roi in roi_list:
        touch(roi_group_dir / f"{roi}_mask.nii")

    for sub in subject_list:
        this_dir = roi_dir / f"sub-{sub}" / "roi"
        this_dir.mkdir(parents=True, exist_ok=True)
        for roi in roi_list:
            for hemi in hemispheres:
                touch(
                    this_dir
                    / f"sub-{sub}_hemi-{hemi}_space-individual_label-{roi}_mask.nii"
                )


if __name__ == "__main__":
    main(
        start_dir=START_DIR,
        subject_list=SUBJECTS,
        session_list=SESSIONS,
        roi_list=ROIS,
        hemispheres=HEMISPHERES,
    )
