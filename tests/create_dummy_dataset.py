from __future__ import annotations

import shutil
from pathlib import Path

import pandas as pd


def touch(path):
    with open(path, "a"):
        pass


def main(start_dir, subject_list, session_list, roi_list, hemispheres):
    # Create BIDS directory structure
    raw_dir = start_dir / "data" / "bidspm-raw"
    derivative_dir = start_dir / "data" / "derivatives"
    preproc_dir = derivative_dir / "bidspm-preproc"
    stats_dir = derivative_dir / "bidspm-stats"
    roi_dir = derivative_dir / "bidspm-roi"

    create_raw_dataset(raw_dir, subject_list, session_list, roi_list, hemispheres)
    create_preproc_dataset(preproc_dir, subject_list, session_list, roi_list, hemispheres)
    create_roi_directories(roi_dir, roi_list, subject_list, hemispheres)
    create_derivatives_dataset(stats_dir, subject_list, session_list)


def create_raw_dataset(target_dir, subject_list, session_list, roi_list, hemispheres):
    # Create the raw BIDS dataset
    for subject in subject_list:
        for ses in session_list:
            create_raw_func_vismotion(target_dir, subject, ses)
            create_raw_func_vislocalizer(target_dir, subject, ses)
            create_raw_fmap(target_dir, subject, ses)

        create_raw_func_rest(target_dir, subject, "02")
        create_raw_anat(target_dir, subject)


def create_raw_func_vismotion(target_dir, subject, ses):
    suffix = "_bold"
    task_name = "vismotion"
    this_dir = target_dir / f"sub-{subject}" / f"ses-{ses}" / "func"
    this_dir.mkdir(parents=True, exist_ok=True)

    basename = f"sub-{subject}_ses-{ses}_task-{task_name}"

    filename = this_dir / f"{basename}_run-1_events.tsv"
    events = {
        "onset": [2, 2],
        "duration": [2, 2],
        "trial_type": ["VisMot", "VisStat"],
    }
    df = pd.DataFrame(events)
    df.to_csv(filename, sep="\t", index=False)

    for run in range(1, 3):
        filename = this_dir / f"{basename}_run-{run}_part-mag{suffix}.nii"
        touch(filename)
        filename = this_dir / f"{basename}_run-{run}_part-phase{suffix}.nii"
        touch(filename)

    filename = this_dir / f"{basename}_run-2_events.tsv"
    events = {
        "onset": [3, 2],
        "duration": [6, 2],
        "trial_type": ["VisStat", "VisMot"],
    }
    df = pd.DataFrame(events)
    df.to_csv(filename, sep="\t", index=False)

    touch(this_dir / f"{basename}_acq-1p60mm_run-1{suffix}.nii")

    for run in [1, 2]:
        filename = this_dir / f"{basename}_acq-1p60mm_run-{run}_events.tsv"
        events = {
            "onset": [4, 2],
            "duration": [8, 2],
            "trial_type": ["VisMot", "VisStat"],
        }
        df = pd.DataFrame(events)
        df.to_csv(filename, sep="\t", index=False)

        touch(this_dir / f"{basename}_acq-1p60mm_dir-PA_run-{run}{suffix}.nii")


def create_raw_func_vislocalizer(target_dir, subject, ses):
    suffix = "_bold"
    task_name = "vislocalizer"
    this_dir = target_dir / f"sub-{subject}" / f"ses-{ses}" / "func"
    this_dir.mkdir(parents=True, exist_ok=True)

    basename = f"sub-{subject}_ses-{ses}_task-{task_name}"
    filename = this_dir / f"{basename}_part-mag{suffix}.nii"
    touch(filename)
    filename = this_dir / f"{basename}_part-phase{suffix}.nii"
    touch(filename)

    events = {
        "onset": [2, 25],
        "duration": [15, 15],
        "trial_type": ["VisMot", "VisStat"],
    }
    df = pd.DataFrame(events)
    df.to_csv(filename, sep="\t", index=False)


def create_raw_func_rest(target_dir, subject, ses):
    suffix = "_bold"
    task_name = "rest"
    this_dir = target_dir / f"sub-{subject}" / f"ses-{ses}" / "func"
    this_dir.mkdir(parents=True, exist_ok=True)

    touch(this_dir / f"sub-{subject}_ses-{ses}_task-{task_name}{suffix}.nii")


def create_raw_fmap(target_dir, subject, ses):
    this_dir = target_dir / f"sub-{subject}" / f"ses-{ses}" / "fmap"
    this_dir.mkdir(parents=True, exist_ok=True)

    fmap_suffix_list = ["_phasediff", "_magnitude1", "_magnitude2"]
    for suffix in fmap_suffix_list:
        touch(this_dir / f"sub-{subject}_ses-{ses}_run-1{suffix}.nii")
        touch(this_dir / f"sub-{subject}_ses-{ses}_run-2{suffix}.nii")

    EchoTime1 = 0.006
    EchoTime2 = 0.00746
    template = '{{"EchoTime1":{}, "EchoTime2":{}, "IntendedFor":"{}"}}'

    suffix = "_bold"

    task_name = "vislocalizer"
    IntendedFor = (
        f"ses-{ses}/func/sub-{subject}_ses-{ses}_task-{task_name}_part-mag{suffix}.nii"
    )
    json_string = template.format(EchoTime1, EchoTime2, IntendedFor)
    with open(this_dir / f"sub-{subject}_ses-{ses}_run-1_phasediff.json", "w") as f:
        f.write(json_string)

    task_name = "vismotion"
    IntendedFor = f"ses-{ses}/func/sub-{subject}_ses-{ses}_task-{task_name}_run-1_part-mag{suffix}.nii"
    json_string = template.format(EchoTime1, EchoTime2, IntendedFor)
    with open(this_dir / f"sub-{subject}_ses-{ses}_run-2_phasediff.json", "w") as f:
        f.write(json_string)


def create_raw_anat(target_dir, subject):
    ses = "01"
    suffix = "_T1w"
    this_dir = target_dir / f"sub-{subject}" / f"ses-{ses}" / "anat"
    this_dir.mkdir(parents=True, exist_ok=True)

    touch(this_dir / f"sub-{subject}_ses-{ses}{suffix}.nii")

    anat_prefix_list = ["m", "c1", "c2", "c3"]
    for prefix in anat_prefix_list:
        touch(this_dir / f"{prefix}sub-{subject}_ses-{ses}{suffix}.nii")

    space = "individual"
    touch(this_dir / f"sub-{subject}_ses-{ses}_space-{space}_desc-biascor{suffix}.nii")
    touch(
        this_dir / f"sub-{subject}_ses-{ses}_space-{space}_desc-skullstripped{suffix}.nii"
    )
    touch(this_dir / f"sub-{subject}_ses-{ses}_space-{space}_desc-preproc{suffix}.nii")
    touch(this_dir / f"sub-{subject}_ses-{ses}_space-{space}_label-brain_mask.nii")
    touch(this_dir / f"sub-{subject}_ses-{ses}_space-{space}_label-CSF_probseg.nii")
    touch(this_dir / f"sub-{subject}_ses-{ses}_space-{space}_label-GM_probseg.nii")
    touch(this_dir / f"sub-{subject}_ses-{ses}_space-{space}_label-WM_probseg.nii")

    space = "IXI549Space"
    touch(
        this_dir / f"sub-{subject}_ses-{ses}_space-{space}_res-bold_label-CSF_probseg.nii"
    )
    touch(
        this_dir / f"sub-{subject}_ses-{ses}_space-{space}_res-bold_label-GM_probseg.nii"
    )
    touch(
        this_dir / f"sub-{subject}_ses-{ses}_space-{space}_res-bold_label-WM_probseg.nii"
    )
    touch(
        this_dir
        / f"sub-{subject}_ses-{ses}_space-{space}_res-hi_desc-preproc{suffix}.nii"
    )
    touch(this_dir / f"sub-{subject}_ses-{ses}_space-{space}_desc-brain_mask.nii")

    touch(
        this_dir / f"sub-{subject}_ses-{ses}_from-IXI549Space_to-T1w_mode-image_xfm.nii"
    )


def create_preproc_dataset(target_dir, subject_list, session_list, roi_list, hemispheres):
    # Create the derivatives BIDS dataset
    for subject in subject_list:
        for ses in session_list:
            create_preproc_func_vismotion(target_dir, subject, ses)
            create_preproc_func_vislocalizer(target_dir, subject, ses)
            create_preproc_fmap(target_dir, subject, ses)

        create_preproc_func_rest(target_dir, subject, "02")
        create_preproc_anat(target_dir, subject)


def create_preproc_func_vismotion(target_dir, subject, ses):
    suffix = "_bold"
    task_name = "vismotion"
    this_dir = target_dir / f"sub-{subject}" / f"ses-{ses}" / "func"
    this_dir.mkdir(parents=True, exist_ok=True)

    basename = f"sub-{subject}_ses-{ses}_task-{task_name}"
    for run in range(1, 3):
        filename = this_dir / f"rp_{basename}_run-{run}_part-mag{suffix}.txt"
        shutil.copy("data/tsv_files/rp.txt", filename)
        shutil.copy(
            "data/tsv_files/rp.tsv",
            this_dir / f"{basename}_run-{run}_part-mag_desc-confounds_regressors.tsv",
        )

        desc_label_list = ["preproc", "mean", "smth6"]
        for desc in desc_label_list:
            touch(
                this_dir
                / f"{basename}_run-{run}_part-mag_space-individual_desc-{desc}{suffix}.nii"
            )
            touch(
                this_dir
                / f"{basename}_run-{run}_part-mag_space-IXI549Space_desc-{desc}{suffix}.nii"
            )
        touch(
            this_dir
            / f"{basename}_run-{run}_part-mag_space-individual_desc-stc{suffix}.nii"
        )
        touch(
            this_dir
            / f"{basename}_run-{run}_part-mag_space-IXI549Space_label-brain_mask.nii"
        )

    if ses == "01":
        touch(this_dir / f"{basename}_part-mag_space-individual_desc-mean{suffix}.nii")
        touch(this_dir / f"{basename}_part-mag_space-IXI549Space_desc-mean{suffix}.nii")
        touch(this_dir / f"mean_{basename}_part-mag{suffix}.nii")


def create_preproc_func_vislocalizer(target_dir, subject, ses):
    suffix = "_bold"
    task_name = "vislocalizer"
    this_dir = target_dir / f"sub-{subject}" / f"ses-{ses}" / "func"
    this_dir.mkdir(parents=True, exist_ok=True)

    filename = this_dir / f"rp_sub-{subject}_ses-{ses}_task-{task_name}{suffix}.txt"
    shutil.copy("data/tsv_files/rp.txt", filename)
    shutil.copy(
        "data/tsv_files/rp.tsv",
        this_dir
        / f"sub-{subject}_ses-{ses}_task-{task_name}_part-mag_desc-confounds_regressors.tsv",
    )

    desc_label_list = ["preproc", "smth6"]
    for desc in desc_label_list:
        touch(
            this_dir
            / f"sub-{subject}_ses-{ses}_task-{task_name}_part-mag_space-individual_desc-{desc}{suffix}.nii"
        )
        touch(
            this_dir
            / f"sub-{subject}_ses-{ses}_task-{task_name}_part-mag_space-IXI549Space_desc-{desc}{suffix}.nii"
        )
        touch(
            this_dir
            / f"sub-{subject}_ses-{ses}_task-{task_name}_part-mag_space-IXI549Space_label-brain_mask.nii"
        )

    touch(
        this_dir / f"mean_sub-{subject}_ses-{ses}_task-{task_name}_part-mag{suffix}.nii"
    )


def create_preproc_fmap(target_dir, subject, ses):
    this_dir = target_dir / f"sub-{subject}" / f"ses-{ses}" / "fmap"
    this_dir.mkdir(parents=True, exist_ok=True)

    fmap_suffix_list = ["_phasediff", "_magnitude1", "_magnitude2"]
    for suffix in fmap_suffix_list:
        touch(this_dir / f"sub-{subject}_ses-{ses}_run-1{suffix}.nii")
        touch(this_dir / f"sub-{subject}_ses-{ses}_run-2{suffix}.nii")

    EchoTime1 = 0.006
    EchoTime2 = 0.00746
    template = '{{"EchoTime1":{}, "EchoTime2":{}, "IntendedFor":"{}"}}'

    suffix = "_bold"

    task_name = "vislocalizer"
    IntendedFor = (
        f"ses-{ses}/func/sub-{subject}_ses-{ses}_task-{task_name}_part-mag{suffix}.nii"
    )
    json_string = template.format(EchoTime1, EchoTime2, IntendedFor)
    with open(this_dir / f"sub-{subject}_ses-{ses}_run-1_phasediff.json", "w") as f:
        f.write(json_string)

    task_name = "vismotion"
    IntendedFor = f"ses-{ses}/func/sub-{subject}_ses-{ses}_task-{task_name}_run-1_part-mag{suffix}.nii"
    json_string = template.format(EchoTime1, EchoTime2, IntendedFor)
    with open(this_dir / f"sub-{subject}_ses-{ses}_run-2_phasediff.json", "w") as f:
        f.write(json_string)


def create_preproc_anat(target_dir, subject):
    ses = "01"
    suffix = "_T1w"
    this_dir = target_dir / f"sub-{subject}" / f"ses-{ses}" / "anat"
    this_dir.mkdir(parents=True, exist_ok=True)

    touch(this_dir / f"sub-{subject}_ses-{ses}{suffix}.nii")

    anat_prefix_list = ["m", "c1", "c2", "c3"]
    for prefix in anat_prefix_list:
        touch(this_dir / f"{prefix}sub-{subject}_ses-{ses}{suffix}.nii")

    space = "individual"
    touch(this_dir / f"sub-{subject}_ses-{ses}_space-{space}_desc-biascor{suffix}.nii")
    touch(
        this_dir / f"sub-{subject}_ses-{ses}_space-{space}_desc-skullstripped{suffix}.nii"
    )
    touch(this_dir / f"sub-{subject}_ses-{ses}_space-{space}_desc-preproc{suffix}.nii")
    touch(this_dir / f"sub-{subject}_ses-{ses}_space-{space}_label-brain_mask.nii")
    touch(this_dir / f"sub-{subject}_ses-{ses}_space-{space}_label-CSF_probseg.nii")
    touch(this_dir / f"sub-{subject}_ses-{ses}_space-{space}_label-GM_probseg.nii")
    touch(this_dir / f"sub-{subject}_ses-{ses}_space-{space}_label-WM_probseg.nii")

    space = "IXI549Space"
    touch(
        this_dir / f"sub-{subject}_ses-{ses}_space-{space}_res-bold_label-CSF_probseg.nii"
    )
    touch(
        this_dir / f"sub-{subject}_ses-{ses}_space-{space}_res-bold_label-GM_probseg.nii"
    )
    touch(
        this_dir / f"sub-{subject}_ses-{ses}_space-{space}_res-bold_label-WM_probseg.nii"
    )
    touch(
        this_dir
        / f"sub-{subject}_ses-{ses}_space-{space}_res-hi_desc-preproc{suffix}.nii"
    )
    touch(this_dir / f"sub-{subject}_ses-{ses}_space-{space}_desc-brain_mask.nii")

    touch(
        this_dir / f"sub-{subject}_ses-{ses}_from-IXI549Space_to-T1w_mode-image_xfm.nii"
    )


def create_roi_directories(roi_dir, roi_list, subject_list, hemispheres):
    # Create ROI directories
    roi_group_dir = roi_dir / "group"
    roi_group_dir.mkdir(parents=True, exist_ok=True)

    for roi in roi_list:
        touch(roi_group_dir / f"{roi}_mask.nii")

    for subject in subject_list:
        this_dir = roi_dir / f"sub-{subject}" / "roi"
        this_dir.mkdir(parents=True, exist_ok=True)
        for roi in roi_list:
            for hemisphere in hemispheres:
                touch(
                    this_dir
                    / f"sub-{subject}_hemi-{hemisphere}_space-individual_label-{roi}_mask.nii"
                )


if __name__ == "__main__":
    start_dir = Path().cwd()
    subject_list = ["ctrl01", "blind01", "01"]
    session_list = ["01", "02"]
    roi_list = ["V1", "A1"]
    hemispheres = ["L", "R"]

    main(start_dir, subject_list, session_list, roi_list, hemispheres)
