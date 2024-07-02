MoAE
****

::

    /demos/MoAE
        ├── models
        └── options

This "Mother of All Experiments" is based on the block design dataset of SPM.

In the ``options`` folder has several examples of how to encode the options of your
analysis in a json file.

In the ``models`` shows the BIDS statistical model used to run the GLM of this demo.

.. automodule:: demos.MoAE

preproc + stats
===============

.. autoscript:: moae_01_bids_app

.. literalinclude:: ../../../demos/MoAE/moae_01_bids_app.m
    :language: matlab
    :linenos:
    :caption: moae_01_bids_app.m
    :lines: 69-175

fmriprep
========

.. autoscript:: moae_fmriprep

.. literalinclude:: ../../../demos/MoAE/moae_fmriprep.m
    :language: matlab
    :linenos:
    :caption: moae_fmriprep.m
    :lines: 19-117

region of interest
==================

.. autoscript:: moae_02_create_roi_extract_data
.. literalinclude:: ../../../demos/MoAE/moae_02_create_roi_extract_data.m
    :language: matlab
    :linenos:
    :caption: moae_02_create_roi_extract_data.m
    :lines: 12-84

slice display
=============

.. autoscript:: moae_03_slice_display
.. literalinclude:: ../../../demos/MoAE/moae_03_slice_display.m
    :language: matlab
    :linenos:
    :caption: moae_03_slice_display.m
    :lines: 11-119

.. .. include:: ../../../demos/MoAE/README.md
..    :parser: myst_parser.sphinx_
