.. _face repetition demo:

Face repetition
***************

This is based on the `event related design dataset of SPM <https://www.fil.ion.ucl.ac.uk/spm/docs/tutorials/fmri/event/>`_.

.. automodule:: demos.face_repetition

preprocessing
=============

.. autoscript:: face_rep_01_bids_app

.. admonition:: script
    :class: dropdown

    .. literalinclude:: ../../../demos/face_repetition/face_rep_01_bids_app.m
        :language: matlab
        :caption: demos/face_repetition/face_rep_01_bids_app.m
        :lines: 27-

preprocessing anat only
=======================

.. autoscript:: face_rep_01_anat_only

.. admonition:: script
    :class: dropdown

    .. literalinclude:: ../../../demos/face_repetition/face_rep_01_anat_only.m
        :language: matlab
        :caption: demos/face_repetition/face_rep_01_anat_only.m
        :lines: 25-

stats
=====

.. autoscript:: face_rep_02_stats

.. admonition:: script
    :class: dropdown

    .. literalinclude:: ../../../demos/face_repetition/face_rep_02_stats.m
        :language: matlab
        :caption: demos/face_repetition/face_rep_02_stats.m
        :lines: 33-

.. admonition:: BIDS stats model
    :class: dropdown

    .. literalinclude:: ../../../demos/face_repetition/models/model-faceRepetition_smdl.json
        :language: json
        :caption: demos/face_repetition/models/model-faceRepetition_smdl.json

stats: parametric analysis
==========================

.. autoscript:: face_rep_02_stats_parametric

.. admonition:: script
    :class: dropdown

    .. literalinclude:: ../../../demos/face_repetition/face_rep_02_stats_parametric.m
        :language: matlab
        :caption: face_rep_02_stats_parametric.m
        :lines: 10-

.. admonition:: BIDS stats model
    :class: dropdown

    .. literalinclude:: ../../../demos/face_repetition/models/model-faceRepetitionParametric_smdl.json
        :language: json
        :caption: demos/face_repetition/models/model-faceRepetitionParametric_smdl.json

region of interest
==================

.. autoscript:: face_rep_03_roi_analysis

.. admonition:: script
    :class: dropdown

    .. literalinclude:: ../../../demos/face_repetition/face_rep_03_roi_analysis.m
        :language: matlab
        :caption: face_rep_02_stats.m
        :lines: 10-

.. admonition:: BIDS stats model
    :class: dropdown

    .. literalinclude:: ../../../demos/face_repetition/models/model-faceRepetition_smdl.json
        :language: json
        :caption: demos/face_repetition/models/model-faceRepetition_smdl.json
