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

The demos show show you different way to use bidspm.

..  toctree::
    :maxdepth: 2

    moae

.. _face repetition demo:

Face repetition
===============

This is based on the event related design dataset of SPM.

.. automodule:: demos.face_repetition
.. autoscript:: face_rep_01_bids_app
.. autoscript:: face_rep_01_anat_only
.. autoscript:: face_rep_02_stats
.. autoscript:: face_rep_03_roi_analysis


Visual motion localizers
========================

.. include:: ../../demos/vismotion/README.md
   :parser: myst_parser.sphinx_

Openneuro based demos
=====================

.. include:: ../../demos/openneuro/README.md
   :parser: myst_parser.sphinx_
