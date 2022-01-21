# Using CPP SPM and datalad

**WORK IN PROGRESS**

Small demo using visual motion localizer data to show how to set up an analysis
with CPP SPM from scratch with datalad.

Ideally better to use the datalad fMRI template we have set up, this shows a set
by step approach.

## Set up

Create a new datalad dataset with a YODA config

```bash
datalad create -c yoda visual_motion_localiser
cd visual_motion_localiser
```

Add the CPP SPM code as a subdataset, checkout the dev branch ands initialises
all submodules.

```
datalad install \
        -d . \
        -s https://github.com/cpp-lln-lab/CPP_SPM.git \
        - r
        code/CPP_SPM
```

In case you get some errors when installing the submodules you might have to
initialise them manually, and update your dataset with that update

```
cd code/CPP_SPM
git checkout dev
git submodule init
cd ..
datalad save -m 'update CPP SPM submodules'
```

Now let's get the raw data as a subdataset and put it in an `inputs/raw` folder.

The data from the CPP lab is openly available on GIN:

https://gin.g-node.org/cpp-lln-lab/CPP_visMotion-raw

Note that to install it you will need to have set up datalad to play nice with GIN:

http://handbook.datalad.org/en/latest/basics/101-139-gin.html

This will install the data:

```
datalad install -d . \
                -s git@gin.g-node.org:/cpp-lln-lab/CPP_visMotion-raw.git \
                inputs/raw
```

After this your datalad dataset should look something like this:

```
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

```
cd inputs/raw
datalad get .
```
