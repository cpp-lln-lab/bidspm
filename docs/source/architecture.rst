Architecture
************

At the highest levels bidspm is organized in workflows:

- they all start with the prefix ``bids`` (for example ``bidsRealignReslice``)
- they are in the folder :mod:`src.workflows`
- they run on all the subjects specified in the ``options`` structure
  (see the :ref:`set-up` section).

Most workflows run by creating matlab batches that are saved as ``.mat`` files in a ``jobs``
then passed to the SPM jobman to run.
To do this the workflows call "batch creating functions":

- all start with the prefix ``setBatch`` (for example ``setBatchCoregistration``).
- are in the folder :mod:`src.batches`.

Many workflows include some post-processing steps (like file renaming) after the execution of the batch,
so in many cases the output of running just the batch and running the whole workflow
will be different.

:ref:`preprocessing`, :ref:`statistics` and :ref:`fieldmaps` handling have their own document pages.

Other workflows, batches and related helper functions are listed below.

Workflows
=========

HRF estimation
--------------

Relies on the resting-state HRF toolbox.

.. automodule:: src.workflows

.. autofunction:: bidsRsHrf

Other
-----

.. autofunction:: bidsCopyInputFolder
.. autofunction:: bidsRename


Worflow helper functions
------------------------

To be used if you want to create a new workflow.

.. autofunction:: setUpWorkflow
.. autofunction:: saveAndRunWorkflow
.. autofunction:: cleanUpWorkflow
.. autofunction:: returnDependency


Batches
=======

.. automodule:: src.batches

.. autofunction:: setBatchSelectAnat
.. autofunction:: setBatchPrintFigure
.. autofunction:: setBatchMeanAnatAndMask
.. autofunction:: setBatchRsHRF
.. autofunction:: setBatchImageCalculation
.. autofunction:: setBatch3Dto4D

.. autofunction:: saveMatlabBatch

.. automodule:: src.batches.lesion

.. autofunction:: setBatchLesionOverlapMap
.. autofunction:: setBatchLesionSegmentation
.. autofunction:: setBatchLesionAbnormalitiesDetection
