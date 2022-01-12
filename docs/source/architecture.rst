Architecture
************

At the highest levels CPP SPM is organized in workflows:
they all start with the prefix `bids` (for example ``bidsRealignReslice``) and are in the folder :mod:`src.workflows`
Workflows typical run on all the subjects specified in the ``options`` structure
(see the :ref:`set-up` section).

Workflows run by creating matlab batches that are then passed to SPM to run.
To do this they call "bacth creating functions"
that all start with the prefix ``setBatch`` (for example ``setBatchCoregistration``).
and are in the folder :mod:`src.batches`.

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

Low level functions description
===============================

Utility functions
-----------------

.. automodule:: src.utils

.. autofunction:: cleanCrash

.. autofunction:: saveOptions
.. autofunction:: loadAndCheckOptions

.. autofunction:: getInfo
.. autofunction:: getData

.. autofunction:: setDirectories
.. autofunction:: createDataDictionary
.. autofunction:: createDerivativeDir
.. autofunction:: createGlmDirName

.. autofunction:: getAnatFilename
.. autofunction:: getBoldFilename
.. autofunction:: getMeanFuncFilename
.. autofunction:: getTpmFilename

.. autofunction:: getFuncVoxelDims
.. autofunction:: getAndCheckSliceOrder
.. autofunction:: getSubjectList

.. autofunction:: renameSegmentParameter
.. autofunction:: renameUnwarpParameter

.. autofunction:: rmTrialTypeStr
.. autofunction:: setFields

.. autofunction:: unzipAndReturnsFullpathName
.. autofunction:: validationInputFile


Print and error handling
------------------------

.. automodule:: src.messages

.. autofunction:: printToScreen
.. autofunction:: errorHandling

.. autofunction:: printWorkflowName
.. autofunction:: printBatchName

.. autofunction:: printCredits
.. autofunction:: printProcessingRun
.. autofunction:: printProcessingSubject


Infrastructure related functions
--------------------------------

.. automodule:: src.infra

.. autofunction:: checkDependencies
.. autofunction:: checkToolbox
.. autofunction:: getEnvInfo
.. autofunction:: getVersion
.. autofunction:: isOctave
.. autofunction:: setGraphicWindow
