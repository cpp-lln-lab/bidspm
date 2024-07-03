.. _moae demo:

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

preprocessing + stats
=====================

.. autoscript:: moae_01_bids_app

.. admonition:: script
    :class: dropdown

    .. literalinclude:: ../../../demos/MoAE/moae_01_bids_app.m
        :language: matlab
        :caption: demos/MoAE/moae_01_bids_app.m
        :lines: 69-

.. admonition:: BIDS stats model
    :class: dropdown

    .. literalinclude:: ../../../demos/MoAE/models/model-MoAE_smdl.json
        :language: json
        :caption: demos/MoAE/models/model-MoAE_smdl.json

stats with fmriprep output + default stats model
================================================

.. autoscript:: moae_fmriprep

.. admonition:: script
    :class: dropdown

    .. literalinclude:: ../../../demos/MoAE/moae_fmriprep.m
        :language: matlab
        :caption: demos/MoAE/moae_fmriprep.m
        :lines: 19-

region of interest
==================

.. autoscript:: moae_02_create_roi_extract_data

.. admonition:: script
    :class: dropdown

    .. literalinclude:: ../../../demos/MoAE/moae_02_create_roi_extract_data.m
        :language: matlab
        :caption: demos/MoAE/moae_02_create_roi_extract_data.m
        :lines: 12-

.. admonition:: BIDS stats model
    :class: dropdown

    .. literalinclude:: ../../../demos/MoAE/models/model-MoAE_smdl.json
        :language: json
        :caption: demos/MoAE/models/model-MoAE_smdl.json

slice display
=============

.. autoscript:: moae_03_slice_display

.. admonition:: script
    :class: dropdown

    .. literalinclude:: ../../../demos/MoAE/moae_03_slice_display.m
        :language: matlab
        :caption: demos/MoAE/moae_03_slice_display.m
        :lines: 11-

.. admonition:: BIDS stats model
    :class: dropdown

    .. literalinclude:: ../../../demos/MoAE/models/model-MoAE_smdl.json
        :language: json
        :caption: model-MoAE_smdl.json

.. .. include:: ../../../demos/MoAE/README.md
..    :parser: myst_parser.sphinx_
