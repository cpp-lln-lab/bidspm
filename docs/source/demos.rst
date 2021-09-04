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

This "Mother of All Experiments" is based on the block design of SPM.

In the ``options`` folder has several examples of how to encode the options of your
analysis in a json file.

In the ``models`` shows the BIDS statistical model used to run the GLM of this demo.

.. automodule:: demos.MoAE
.. autoscript:: moae_01_preproc
.. autoscript:: moae_02_stats
.. autoscript:: moae_03_create_roi_extract_data
.. autoscript:: moae_04_slice_display
