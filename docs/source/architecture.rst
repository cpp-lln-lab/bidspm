Architecture
************

At the highest levels bidspm is organized in workflows:

- they all start with the prefix ``bids`` (for example ``bidsRealignReslice``)
- they are in the folder :mod:`src.workflows`
- they run on all the subjects specified in the ``options`` structure.

Most workflows run by creating matlab batches that are saved as ``.mat`` files in a ``jobs``
then passed to the SPM jobman to run.
To do this the workflows call "batch creating functions":

- all start with the prefix ``setBatch`` (for example ``setBatchCoregistration``).
- are in the folder :mod:`src.batches`.

Many workflows include some post-processing steps (like file renaming) after the execution of the batch,
so in many cases the output of running just the batch and running the whole workflow
will be different.

:ref:`preprocessing`, :ref:`statistics` and :ref:`fieldmaps_page` handling have their own document pages.

Other workflows, batches and related helper functions are listed below.

Workflows
=========

HRF estimation
--------------

Relies on the resting-state HRF toolbox.

:func:`src.workflows.bidsRsHrf`

Other
-----

:func:`src.workflows.bidsCopyInputFolder`
:func:`src.workflows.bidsRename`


Workflow helper functions
-------------------------

To be used if you want to create a new workflow.

:func:`src.workflows.setUpWorkflow`
:func:`src.workflows.saveAndRunWorkflow`
:func:`src.workflows.cleanUpWorkflow`
:func:`src.workflows.returnDependency`


Batches
=======

:func:`src.batches.setBatchSelectAnat`
:func:`src.batches.setBatchPrintFigure`
:func:`src.batches.setBatchMeanAnatAndMask`
:func:`src.batches.setBatchRsHRF`
:func:`src.batches.setBatchImageCalculation`
:func:`src.batches.setBatch3Dto4D`

:func:`src.batches.saveMatlabBatch`

:func:`src.batches.setBatchLesionOverlapMap`
:func:`src.batches.setBatchLesionSegmentation`
:func:`src.batches.setBatchLesionAbnormalitiesDetection`
