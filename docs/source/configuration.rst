.. _configuration:

Configuration
*************

Options
#######

Most of the options you have chosen for your analysis will be set in a variable
``opt`` an Octave/Matlab structure.

Documentation on the options can be found here: :func:`src.defaults.checkOptions`.

The content of that structure can be defined:

- "at run" time in a script or a function
- in a separate json file that can be loaded with :func:`src/IO/loadAndCheckOptions.m`.

You can find examples of both in the ``demos`` folder.


Selecting groups and subjects
=============================

The way to select certain subjects is summarised in the documentation of the
:func:`src/bids/getSubjectList.m` function.


Setting directories
===================

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

To run a GLM, bidspm gets the images and confound time series from a preprocessed
derivatives BIDS dataset (from fMRIprep or bidspm) and the ``events.tsv`` files
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

Defaults
########

``checkOptions``
================

The defaults are handled mostly by those functions:

- :func:`src.defaults.checkOptions`
- :func:`src.defaults.setDirectories`
- :func:`src.defaults.defaultResultsStructure`
- :func:`src.defaults.defaultContrastsStructure`

``spm_my_defaults``
===================

Some more SPM options can be set in the :func:`src.defaults.spm_my_defaults`.

statistics defaults
===================

Note that some of the defaults value may be over-ridden by the content of the ``opt``
structure but also by the content of your BIDS stats model.

.. _auto_correlation_model:

auto-correlation modelisation
-----------------------------

Use of FAST :cite:p:`Olszowy2019` and not AR1 for auto-correlation modelisation.

Using FAST does not seem to affect results on time series with "normal" TRs but
improves results when using sequences: it is therefore used by default in this
pipeline.


SPM to BIDS filename conversion
===============================

:func:`src.defaults.set_spm_2_bids_defaults`


List of defaults
################

.. only:: html

    .. literalinclude:: default_options.m
        :language: matlab
