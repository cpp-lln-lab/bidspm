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

The actual `opt.dir.input` and `opt.dir.output` folders 
will usually be set automatically when running::

    opt = checkOptions(opt)

But you can set those by hand if you prefer.

BIDS model JSON files
---------------------

This files allow you to specify the GLM to run and which contrasts to run.
It follows `BIDS statistical model <https://docs.google.com/document/d/1bq5eNDHTb6Nkx3WUiOBgKvLNnaa5OMcGtD0AZ9yms2M/edit?usp=sharing)>`_

The model json file that describes:

-   out to prepare the regressors for the GLM: ``Transformation``
-   the design matrix: ``X``
-   the contrasts to compute: ``contrasts``

It also allows to specify those for different levels of the analysis:

-   run
-   session
-   subject
-   dataset

An example of json file could look something like that:

.. code-block:: json

    {
        "Name": "Basic",
        "Description": "",
        "Input": {
            "task": "motionloc"
        },
        "Nodes": [
            {
                "Level": "Subject",
                "DummyContrasts": ["stim_type.motion", "stim_type.static"],
                "Contrasts": [
                    {
                        "Name": "motion_vs_static",
                        "ConditionList": ["stim_type.motion", "stim_type.static"],
                        "weights": [1, -1],
                        "type": "t"
                    }
                ]
            },
            {
                "Level": "Dataset",
                "DummyContrasts": [
                    "stim_type.motion",
                    "stim_type.static",
                    "motion_vs_static"
                ]
            }
        ]
    }


In brief this means:

-   at the subject level automatically compute the t contrast against baseline
    for the condition ``motion`` and ``static`` and compute the t-contrats for motion
    VS static with these given weights.
-   at the level of the data set (so RFX) do the t contrast of the ``motion``,
    ``static``, ``motion VS static``.

We are currently using this to run different subject level GLM models for our
univariate and multivariate analysis where in the first one we compute a con
image that averages the beta images of all the runs where as in the latter case
we get one con image for each run.


To create a default model for a given BIDS dataset you can do this:

.. code-block:: matlab

    path_to_dataset = fullfile(pwd, 'data', 'raw');
    BIDS = bids.layout(path_to_dataset);

    opt.taskName = 'myFascinatingTask';

    createDefaultStatsModel(BIDS, opt);
