<!-- the section below is automatically generated.

If you want to modify the questions:
- please edit the files in the `faq` folder in the doc

-->

# Stats

## How can change the name of the folder of the subject level analysis?

This can be done by changing the `Name` of the run level `Nodes`
in the BIDS stats model.

If your `Nodes.Name` is one of the "default" values:

- `"run"`
- `"run level"`
- `"run_level"`
- `"run-level"`
- ...

like in the example below

```json
  "Nodes": [
    {
      "Level": "Run",
      "Name": "run_level",
    }
  ]
```

then {func}`src.stats.subject_level.getFFXdir.m` will set the subject level folder to be named as follow:

```text
sub-subLabel
└── task-taskLabel_space-spaceLabel_FWHM-FWHMValue
```

However if your `Nodes.Name` is not one of the "default" values, like this

```json
  "Nodes": [
    {
      "Level": "Run",
      "Name": "parametric",
    }
  ]
```

then the subject level folder to be named as follow:

```text
sub-subLabel
└── task-taskLabel_space-spaceLabel_FWHM-FWHMValue_node-parametric
```

## How can I see what the transformation in the BIDS stats model will do to my events.tsv?

You can use the `bids.util.plot_events` function to help you visualize what events will be used in your GLM.

If you want to vivualize the events file:

```matlab
bids.util.plot_events(path_to_events_files);
```

This assumes the events are listed in the `trial_type` column (though this can be
changed by the `trial_type_col` parameter).

If you want to see what events will be included in your GLM after the transformations
are applied:

```matlab
bids.util.plot_events(path_to_events_files, 'model_file', path_to_bids_stats_model_file);
```

This assumes the transformations to apply are in the root node eof the model.

In case you want to save the output after the transformation:

```matlab
% load the events and the stats model
data = bids.util.tsvread(path_to_events_files);
model = BidsModel('file', path_to_bids_stats_model_file);

% apply the transformation
transformers = model.Nodes{1}.Transformations.Instructions;
[new_content, json] = bids.transformers(transformers, data);

% save the new TSV for inspection to make sure it looks like what we expect
bids.util.tsvwrite(fullfile(pwd, 'new_events.tsv'), new_content);
```

## How should I name my conditions in my events.tsv?

In BIDS format, conditions should be named in the `trial_type` column of the `events.tsv` file.

Some good practices for naming "things" can probably be applied here.

- use only alphanumeric characters, underscores and hyphens,
avoid spaces in the condition names

For example: `foo_bar` is ok, but `f$o}o b^a*r` is not.

- the condition names should be short AND descriptive AND human readable

For example: `1` or `one` or `condition1` are short but not descriptive.

An extra requirement to have condition names that can work with bidspm
is that condition names ending with an underscore followed by one or more digits
may lead to unwanted behavior (error or nothing happening
- see [issue](https://github.com/cpp-lln-lab/bidspm/issues/973))
when computing results of a GLM.

So for example:

`happy_face1` and `house123` are ok, but `happy_face_1` and `house_123`  are not.

If your BIDS dataset has conditions that do not follow this rule,
then you can use
the [`Replace` variable transform](https://github.com/bids-standard/variable-transform/blob/main/spec/munge.md#replace)
in your [BIDS statistical model](https://bidspm.readthedocs.io/en/latest/bids_stats_model.html#transformation')
to rename them on the fly without having to manually edit potentially dozens of files.

See also example below.

Say one of your events.tsv files looks like this:

|   onset |   duration | trial_type   |
|--------:|-----------:|:-------------|
|       2 |          2 | happy_face_1 |
|       4 |          2 | house_2      |
|       5 |          2 | happy_face_2 |
|       8 |          2 | house_4      |

You can add the following transformation to the first node (usually the run level node)
of your BIDS stats model.

```json
{
  "Nodes": [
    {
      "Level": "Run",
      "Name": "run_level",
      "GroupBy": [
        "run",
        "subject"
      ],
      "Transformations": {
        "Description": "Replace",
        "Instruction": [
            {
                "Name": "Replace",
                "Input": "trial_type",
                "Replace": [
                    {
                        "key": "happy_face_1",
                        "value": "happy_face1"
                    },
                    {
                        "key": "house_2",
                        "value": "house2"
                    },
                    {
                        "key": "happy_face_2",
                        "value": "happy_face2"
                    },
                    {
                        "key": "house_4",
                        "value": "house4"
                    }
                ]
            }
        ]
    },
      "Model": {
        "X": [
            "trial_type.happy_face*",
            "trial_type.house*"
          ],
        "Description": "the rest of the bids stats model would go below this as usual."

    }
    }
  ]
}
```

Related issue: https://github.com/cpp-lln-lab/bidspm/issues/973

## How should I structure my data to run my statistical analysis?

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

---

Generated by [FAQtory](https://github.com/willmcgugan/faqtory)
