---
title: "Statistics: How should I structure my data to run my statistical analysis?"
---

The main thing to remember is that bidspm will read the events.tsv files from
your raw BIDS data set and will read the bold images from a `bidspm-preproc`
folder.

If your data was preprocessed with fmriprep, bidspm will first need to copy,
unzip and smooth the data into a `bidspm-preproc` folder

Here is an example of how the data is organized for the MoAE fmriprep demo and
what the `bidspm` BIDS call would look like.

```bash
├── inputs
│   ├── fmriprep                     # fmriprep preprocessed BIDS dataset
│   |   ├── dataset_description.json
│   │   └── sub-01
│   │       ├── anat
│   │       ├── figures
│   │       └── func
│   │           ├── sub-01_task-auditory_desc-confounds_timeseries.json
│   │           ├── sub-01_task-auditory_desc-confounds_timeseries.tsv
│   │           ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-brain_mask.json
│   │           ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-brain_mask.nii.gz
│   │           ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-preproc_bold.json
│   │           └── sub-01_task-auditory_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz
│   └── raw                          # raw BIDS dataset
│       ├── dataset_description.json
│       ├── README
│       ├── sub-01
│       │   ├── anat
│       │   │   └── sub-01_T1w.nii
│       │   └── func
│       │       ├── sub-01_task-auditory_bold.nii
│       │       └── sub-01_task-auditory_events.tsv
│       └── task-auditory_bold.json
├── models                            # models used to run the GLM
│   ├── model-MoAEfmriprep_smdl.json
│   ├── model-MoAEindividual_smdl.json
│   └── model-MoAE_smdl.json
├── options
└── outputs
    └── derivatives
        └── bidspm-preproc          # contains data taken from fmriprep and smoothed
            ├── dataset_description.json
            ├── README
            ├── jobs
            │   └── auditory
            │       └── sub-01
            └── sub-01
                ├── anat
                └── func
                    ├── sub-01_task-auditory_desc-confounds_timeseries.json
                    ├── sub-01_task-auditory_desc-confounds_timeseries.tsv
                    ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-brain_mask.json
                    ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-brain_mask.nii
                    ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-preproc_bold.json
                    ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-preproc_bold.nii
                    ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-smth8_bold.json
                    └── sub-01_task-auditory_space-MNI152NLin6Asym_desc-smth8_bold.nii
```

```matlab
WD = fileparts(mfilename('fullpath'));

subject_label = '01';

bids_dir = fullfile(WD, 'inputs', 'raw');
output_dir = fullfile(WD, 'outputs', 'derivatives');
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

model_file = fullfile(pwd, 'models', 'model-MoAEfmriprep_smdl.json');

bidspm(bids_dir, output_dir, 'subject', ...
        'participant_label', {subject_label}, ...
        'action', 'stats', ...
        'preproc_dir', preproc_dir, ...
        'model_file', model_file, ...
        'fwhm', 8, ...
        'options', opt);
```
