Small demo using visual motion localizer data to show how to set up an analysis
with BIDSpm from scratch with datalad.

# Using BIDSpm and datalad

Ideally better to use the datalad fMRI template we have set up, this shows a set
by step approach.

```{note}
The bash script `vismotion_demo.sh` will run all the steps described here in one
fell swoop.
```

You can run it by typing the following from within the bidspm/demos/vismotion

```bash
bash vismotion_demo.sh
```

## Set up

Create a new datalad dataset with a YODA config

```bash
datalad create -c yoda visual_motion_localiser
cd visual_motion_localiser
```

Add the BIDSpm code as a sub-dataset, checkout the dev branch ands initializes

all submodules.

```bash
datalad install \
    -d . \
    -s https://github.com/cpp-lln-lab/bidspm.git \
    --branch dev \
    -r \
    code/bidspm
```

In case you get some errors when installing the submodules you might have to
initialize them manually, and update your dataset with that update

```bash
cd code/bidspm
git checkout dev
git submodule update --init --recursive && git submodule update --recursive
cd ..
datalad save -m 'update BIDSpm submodules'
```

Now let's get the raw data as a subdataset and put it in an `inputs/raw` folder.

The data from the CPP lab is openly available on GIN:
[https://gin.g-node.org/cpp-lln-lab/Toronto_VisMotionLocalizer_MR_raw](https://gin.g-node.org/cpp-lln-lab/Toronto_VisMotionLocalizer_MR_raw)

Note that to install it you will need to have set up Datalad to play nice with
GIN: see the
[datalad handbook](http://handbook.datalad.org/en/latest/basics/101-139-gin.html)

This will install the data:

```bash
datalad install -d . \
                -s git@gin.g-node.org:/cpp-lln-lab/Trento_VisMotionLocalizer_MR_raw.git \
                --recursive \
                inputs/raw
```

After this your datalad dataset should look something like this:

```bash
├── code
│   └── bidspm
└── inputs
    └── raw
        ├── derivatives
        │   └── fmriprep
        ├── sub-con07
        ├── sub-con08
        └── sub-con15
```

To finish the setup you need to download the data:

```bash
cd inputs/raw
datalad get .
```

Note that you could have installed the dataset and got the data in one command:

## Running the analysis

Start matlab and run the `step_1_preprocess.m` and `step_2_stats.m` scripts.

In the end your whole analysis should look like this.

```bash
├── code
│   └── bidspm
│       ├── binder
│       ├── demos
│       │   ├── face_repetition
│       │   ├── lesion_detection
│       │   ├── MoAE
│       │   ├── openneuro
│       │   ├── tSNR
│       │   └── vismotion          # <--- your scrips are there
│       ├── docs
│       ├── lib
│       ├── manualTests
│       ├── notebooks
│       ├── src
│       ├── templates
│       └── tests
├── inputs
│   └── raw                        # <--- input data
│       ├── derivatives
│       │   └── fmriprep           # <--- fmriprep data
│       ├── sub-con07
│       │   └── ses-01
│       ├── sub-con08
│       │   └── ses-01
│       └── sub-con15
│           └── ses-01
└── outputs
    └── derivatives
        ├── bidspm-preproc        # <--- smoothed data
        │   ├── jobs
        │   ├── sub-con07
        │   ├── sub-con08
        │   └── sub-con15
        └── bidspm-stats          # <--- stats output
            ├── jobs
            ├── sub-con07
            ├── sub-con08
            └── sub-con15
```
