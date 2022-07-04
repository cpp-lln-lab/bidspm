Demos
*****

::

    demos/
        ├── face_repetition
        ├── lesion_detection
        ├── MoAE
        ├── openneuro
        ├── tSNR
        └── vismotion

The demos show show you different way to use CPP_SPM.

MoAE
====

::

    /demos/MoAE
        ├── models
        └── options

This "Mother of All Experiments" is based on the block design dataset of SPM.

In the ``options`` folder has several examples of how to encode the options of your
analysis in a json file.

In the ``models`` shows the BIDS statistical model used to run the GLM of this demo.

.. automodule:: demos.MoAE
.. autoscript:: moae_01_bids_app
.. autoscript:: moae_fmriprep
.. autoscript:: moae_02_create_roi_extract_data
.. autoscript:: moae_03_slice_display

.. _face repetition demo:

Face repetition
===============

This is based on the event related design dataset of SPM.

.. automodule:: demos.face_repetition
.. autoscript:: face_rep_01_bids_app
.. autoscript:: face_rep_01_anat_only
.. autoscript:: face_rep_02_stats
.. autoscript:: face_rep_03_roi_analysis
.. autoscript:: face_rep_resolution


Visual motion localizers
========================

.. include:: ../../demos/vismotion/README.md
   :parser: myst_parser.sphinx_

Openneuro based demos
=====================

.. include:: ../../demos/openneuro/README.md
   :parser: myst_parser.sphinx_
