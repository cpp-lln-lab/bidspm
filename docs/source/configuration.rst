.. _configuration:

Configuration
*************

Options
#######

Most of the options you have chosen for your analysis will be set in a variable
``opt`` an Octave/Matlab structure.

Documentation on the options can be found here: :func:`checkOptions`.

The content of that structure can be defined:

- at run time in a script or a function
- in a separate json file (that will be loaded with :func:`loadAndCheckOptions`).

You can find examples of both in the ``demos`` folder.

See :func:`checkOptions` for a list of all the options set by that function.

See :func:`bidsResults` for more details on the options to set to get specific results.

Defaults
########

The defaults are handled mostly by those functions:

- :func:`checkOptions`
- :func:`setDirectories`
- :func:`defaultResultsStructure`
- :func:`defaultContrastsStructure`

``spm_my_defaults``
===================

Some more SPM options can be set in the :func:`spm_my_defaults`.

statistics defaults
===================

Note that some of the defaults value may be over-ridden by the content of the ``opt``
structure but also by the content of your BIDS stats model.

.. _serial_correlation_model:

Serial correlation modelisation
-------------------------------

Use of FAST :cite:p:`Olszowy2019` and not AR1 for auto-correlation modelisation.

Using FAST does not seem to affect results on time series with "normal" TRs but
improves results when using sequences: it is therefore used by default in this
pipeline.

See the Software section in the :ref:`bids_stats_model` page if you want to use
the BIDS stats model to change the serial correlation modelisation.

SPM to BIDS filename conversion
===============================

:func:`set_spm_2_bids_defaults`

Setting directories
===================

Below are some example on how to specify input and output directories.

.. note::
    It will be easier and make your code more portable,
    if you use relative path for your directory setting.

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
will usually be set automatically when running:

.. code-block:: matlab

    opt = checkOptions(opt)

But you can set those by hand if you prefer.

.. only:: html

  .. admonition:: List of defaults
      :class: dropdown

      .. literalinclude:: default_options.m
          :language: matlab
