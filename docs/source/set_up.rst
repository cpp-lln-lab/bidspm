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
