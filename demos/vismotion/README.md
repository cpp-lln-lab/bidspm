Small demo using visual motion localizer data to show how to set up an analysis
with CPP SPM from scratch with datalad.

# Using CPP SPM and datalad

Ideally better to use the datalad fMRI template we have set up, this shows a set
by step approach.

```{note}
The bash script `vismotion_demo.sh` will run all the steps described here in one
fell swoop.
```

You can run it by typing the following from within the CPP_SPM/demos/vismotion

```bash
bash vismotion_demo.sh
```

## Set up

Create a new datalad dataset with a YODA config

```bash
datalad create -c yoda visual_motion_localiser
cd visual_motion_localiser
```

Add the CPP SPM code as a sub-dataset, checkout the dev branch ands initializes
all submodules.

```bash
datalad install \
        -d . \
        -s https://github.com/cpp-lln-lab/CPP_SPM.git \
        -r
        code/CPP_SPM
```

In case you get some errors when installing the submodules you might have to
initialize them manually, and update your dataset with that update

```bash
cd code/CPP_SPM
git checkout dev
git submodule init
cd ..
datalad save -m 'update CPP SPM submodules'
```

Now let's get the raw data as a subdataset and put it in an `inputs/raw` folder.

The data from the CPP lab is openly available on GIN:
[https://gin.g-node.org/cpp-lln-lab/CPP_visMotion-raw](https://gin.g-node.org/cpp-lln-lab/CPP_visMotion-raw)

Note that to install it you will need to have set up Datalad to play nice with
GIN: see the
[datalad handbook](http://handbook.datalad.org/en/latest/basics/101-139-gin.html)

This will install the data:

```bash
datalad install -d . \
                -s git@gin.g-node.org:/cpp-lln-lab/CPP_visMotion-raw.git \
                inputs/raw
```

After this your datalad dataset should look something like this:

```bash
├── code
│   └── CPP_SPM
│       ├── binder
│       ├── demos
│       ├── docs
│       ├── lib
│       ├── manualTests
│       ├── notebooks
│       ├── src
│       ├── templates
│       └── tests
└── inputs
    └── raw
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

```bash
datalad install -d . \
    --get-data \
    -s git@gin.g-node.org:/cpp-lln-lab/CPP_visMotion-raw.git \
    inputs/raw
```

## Running the analysis

Start matlab and run the `step_1_preprocess.m` and `step_2_stats.m` scripts.

In the end your whole analysis should look like this.

```bash
├── code
│   └── CPP_SPM
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
│       ├── sub-con07
│       │   └── ses-01
│       ├── sub-con08
│       │   └── ses-01
│       └── sub-con15
│           └── ses-01
└── outputs
    └── derivatives
        ├── cpp_spm-preproc        # <--- preprocessed data
        │   ├── jobs
        │   ├── sub-con07
        │   ├── sub-con08
        │   └── sub-con15
        └── cpp_spm-stats          # <--- stats output
            ├── jobs
            ├── sub-con07
            ├── sub-con08
            └── sub-con15
```
