Function description
********************

Subject level model
===================

.. automodule:: src.subject_level

.. autofunction:: createAndReturnOnsetFile
.. autofunction:: deleteResidualImages
.. autofunction:: getBoldFilenameForFFX
.. autofunction:: getFFXdir
.. autofunction:: specifyContrasts

Functions to deal with onsets files and confounds regressors.

.. autofunction:: convertOnsetTsvToMat
.. autofunction:: convertRealignParamToTsv
.. autofunction:: createAndReturnCounfoundMatFile
.. autofunction:: getConfoundsRegressorFilename
.. autofunction:: getRealignParamFilename

Group level model
=================

.. automodule:: src.group_level
.. autofunction:: getRFXdir


Utility functions
=================

.. automodule:: src.utils

.. autofunction:: cleanCrash
.. autofunction:: createDataDictionary
.. autofunction:: createDerivativeDir
.. autofunction:: createGlmDirName
.. autofunction:: getAnatFilename
.. autofunction:: getBoldFilename
.. autofunction:: getData
.. autofunction:: getFuncVoxelDims
.. autofunction:: getInfo
.. autofunction:: getMeanFuncFilename
.. autofunction:: getSliceOrder
.. autofunction:: getSubjectList
.. autofunction:: getTpmFilename
.. autofunction:: loadAndCheckOptions
.. autofunction:: renameSegmentParameter
.. autofunction:: renameUnwarpParameter
.. autofunction:: rmTrialTypeStr
.. autofunction:: saveMatlabBatch
.. autofunction:: saveOptions
.. autofunction:: setDirectories
.. autofunction:: setFields
.. autofunction:: unzipImgAndReturnsFullpathName
.. autofunction:: validationInputFile


Print and error handling
========================

.. automodule:: src.messages

.. autofunction:: errorHandling
.. autofunction:: printBatchName
.. autofunction:: printCredits
.. autofunction:: printProcessingRun
.. autofunction:: printProcessingSubject
.. autofunction:: printToScreen
.. autofunction:: printWorkflowName


Infrastructure related functions
================================

.. automodule:: src.infra

.. autofunction:: checkDependencies
.. autofunction:: checkToolbox
.. autofunction:: getEnvInfo
.. autofunction:: getVersion
.. autofunction:: isOctave
.. autofunction:: manageWorkersPool
.. autofunction:: setGraphicWindow