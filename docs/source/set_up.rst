.. _set-up:

Set up
******

Configuration of the pipeline
=============================

Options
-------

Most of the options you have chosen for your analysis will be set in a variable
``opt`` an Octave/Matlab structure.

The content of that structure can be defined:

- "at run" time in a script or a function (that often called ``getOption``)
- in a separate json file that can be loaded with :func:`src/utils/loadAndCheckOptions.m`.

You can find examples of both in the ``demos`` folder. You can also find a
template function for ``getOption`` in the ``templates`` folder.

Check the  :ref:`defaults` page to see the available options and their defaults.

Selecting groups and subjects
+++++++++++++++++++++++++++++

The way to select certain subjects is summarised in the documentation of the
:func:`src/utils/getSubjectList` function.

.. automodule:: src.bids

.. autofunction:: getSubjectList
    :noindex:

Setting directories
+++++++++++++++++++

Below are some example on how to specify input and output directories.

.. note::
    It will be easier and make your code more portable, if you use relative path
    for your directory setting.

**For preprocessing**

For a given folder structure::

  my_fmri_project
    ├── code
    │   └── getOptionPreproc.m
    ├── outputs/derivatives
    └── inputs
        └── raw

Example content of ``getOptionPreproc`` file:

.. code-block:: matlab

  opt.pipeline.type = 'preproc';

  this_dir = fileparts(mfilename('fullpath'));

  opt.dir.raw = fullfile(this_dir, '..' 'inputs', 'raw');
  opt.dir.derivatives = fullfile(this_dir, '..', 'outputs', 'derivatives');

**For statistics**

To run a GLM, CPP SPM gets the images and confound time series from a preprocessed
derivatives BIDS dataset (from fMRIprep or CPP SPM) and the ``events.tsv`` files
from a raw BIDS dataset.

For a given folder structure::

  my_fmri_project
    ├── code
    │   └── getOptionStats.m
    ├── outputs/derivatives
    └── inputs
        ├── fmriprep
        └── raw

Example content of ``getOptionStats`` file:

.. code-block:: matlab

  opt.pipeline.type = 'stats';

  this_dir = fileparts(mfilename('fullpath'));

  opt.dir.raw = fullfile(this_dir, '..', 'inputs', 'raw');
  opt.dir.preproc = fullfile(this_dir, '..', 'inputs', 'fmriprep');
  opt.dir.derivatives = fullfile(this_dir, '..', 'outputs', 'derivatives');

The actual ``opt.dir.input`` and ``opt.dir.output`` folders
will usually be set automatically when running::

    opt = checkOptions(opt)

But you can set those by hand if you prefer.

BIDS model JSON files
---------------------

This files allow you to specify the GLM to run and which contrasts to run.
It follows `BIDS statistical model <https://docs.google.com/document/d/1bq5eNDHTb6Nkx3WUiOBgKvLNnaa5OMcGtD0AZ9yms2M/edit?usp=sharing)>`_

The model JSON file that describes:

-   out to prepare the regressors for the GLM: ``Transformation``
-   the design matrix: ``X``
-   the contrasts to compute: ``contrasts``
-   several other options

It also allows to specify those for different levels of the analysis:

-   run
-   subject
-   dataset

An example of JSON file could look something like that:

.. code-block:: json

    {
        "Name": "Basic model",
        "Description": "model for motion localizer",
        "Input": {
            "space": "IXI549Space",
            "task": "motionloc"
        },
        "Nodes": [
            {
                "Level": "Run",
                "Transformations": {
                    "Transformer": "cpp_spm",
                    "Instructions": [
                        {
                            "Name": "Subtract",
                            "Input": [
                                "trial_type.motion",
                                "trial_type.static"
                            ],
                            "Value": 3,
                            "Output": [
                                "motion",
                                "static"
                            ]
                        }
                    ]
                },
                "Model": {
                    "Type": "glm",
                    "X": [
                        "motion",
                        "static",
                        "trans_?",
                        "rot_?",
                        "*outlier*"
                    ],
                    "HRF": {
                        "Variables": [
                            "motion",
                            "static"
                        ],
                        "Model": "DoubleGamma"
                    },
                    "Options": {
                        "HighPassFilterCutoffHz": 0.0078,
                        "Mask": ""
                    },
                    "Software": {
                        "SPM": {
                            "HRFderivatives": "Temporal",
                            "SerialCorrelation": "FAST"
                        }
                    }
                },
                "DummyContrasts": {
                    "Test": "t",
                    "Contrasts": [
                      "motion",
                      "static"
                    ]
                  },
                "Contrasts": [
                    {
                        "Name": "motion_vs_static",
                        "ConditionList": [
                            "motion",
                            "static"
                        ],
                        "weights": [
                            1,
                            -1
                        ],
                        "type": "t"
                    }
                ]
            }
        ]
    }


Here are what the different section mean:

.. code-block:: json

        "Input": {
            "space": "IXI549Space",
            "task": "motionloc"
        }

This allows you to specify input images you want to include based
on the BIDS entities in their name, like the task (can be more than one) or the
MNI space your images are in (here ``IXI549Space`` is for SPM 12 typical MNI space.

Then the model has a ``Nodes`` array where each objectin defines
what is to be done at a given ``Level`` (``Run``, ``Subject``, ``Dataset``)

.. code-block:: json

        "Nodes": [
            {
                "Level": "Run",


The ``Transformations`` object allows you to define what you want to do to some variables,
before you put them in the design matrix. Here this shows how to subtract 3 seconds
from the event onsets of the conditions listed in the ``trial_type`` columns of the
``events.tsv`` file, and put the output in a variable called ``motion`` and ``static``.

.. code-block:: json

                "Transformations": {
                    "Transformer": "cpp_spm",
                    "Instructions": [
                        {
                            "Name": "Subtract",
                            "Input": [
                                "trial_type.motion",
                                "trial_type.static"
                            ],
                            "Value": 3,
                            "Output": [
                                "motion",
                                "static"
                            ]
                        }
                    ]
                }

Then comes the model object,

``X`` defines the variables that have to be put in
the design matrix. Here ``trans_?`` means any of the translation parameters
(in this case ``trans_x``, ``trans_y``, ``trans_z``) from the realignment
that are stored in ``_confounds.tsv`` files. Similarly ``*outlier*`` means that any
"scrubbing" regressors created by fMRIprep or CPP SPM to detect motion outlier or potential
dummy scans will be included (those regressors are also in the ``_confounds.tsv`` files).

.. note::

    Following standard Unix-style glob rules,
    “*” is interpreted to match 0 or more alphanumeric characters,
    and “?” is interpreted to match exactly one alphanumeric character.

``HRF`` specifies which variables of X have to be convolved and what HRF model to
use to do so.

.. code-block:: json

                "Model": {
                    "Type": "glm",
                    "X": [
                        "motion",
                        "static",
                        "trans_?",
                        "rot_?",
                        "*outlier*"
                    ],
                    "HRF": {
                        "Variables": [
                            "motion",
                            "static"
                        ],
                        "Model": "DoubleGamma"
                    }


Then we have the contrasts definition where ``DummyContrasts``
compute the contrasts against baseline for the condition ``motion`` and ``static``
and where ``Contrasts`` compute the t-contrats for "motion greater than static"
with these given weights.

.. code-block:: json

                "DummyContrasts": {
                    "Test": "t",
                    "Contrasts": [
                      "motion",
                      "static"
                    ]
                  },
                "Contrasts": [
                    {
                        "Name": "motion_gt_static",
                        "ConditionList": [
                            "motion",
                            "static"
                        ],
                        "weights": [
                            1,
                            -1
                        ],
                        "type": "t"
                    }
                ]


Create an empty BIDS model
--------------------------

.. code-block:: matlab

    model = createEmptyModel()
    bids.util.jsonwrite('model-empty_smdl.json', model)

Create a default BIDS model for a dataset
-----------------------------------------

.. code-block:: matlab

    path_to_dataset = fullfile(pwd, 'data', 'raw');
    BIDS = bids.layout(path_to_dataset);

    opt.taskName = 'myFascinatingTask';

    createDefaultStatsModel(BIDS, opt);
