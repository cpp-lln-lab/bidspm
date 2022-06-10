Low level functions description
===============================

BIDS related functions
----------------------

.. automodule:: src.bids

.. autofunction:: initBids

.. autofunction:: addStcToQuery
.. autofunction:: removeEmptyQueryFields

.. autofunction:: getROIs

.. autofunction:: getInfo
.. autofunction:: getSubjectList
.. autofunction:: getAndCheckRepetitionTime
.. autofunction:: getAndCheckSliceOrder

.. autofunction:: getTpmFilename
.. autofunction:: getMeanFuncFilename
.. autofunction:: getBoldFilename
.. autofunction:: getAnatFilename

Input / Output
--------------

.. automodule:: src.IO

.. autofunction:: getData

.. autofunction:: saveOptions
.. autofunction:: loadAndCheckOptions

.. autofunction:: overwriteDir
.. autofunction:: createDerivativeDir

.. autofunction:: saveSpmScript

.. autofunction:: unzipAndReturnsFullpathName

.. autofunction:: onsetsMatToTsv
.. autofunction:: regressorsMatToTsv

.. autofunction:: renameUnwarpParameter
.. autofunction:: renameSegmentParameter

.. autofunction:: cleanCrash

Utility functions
-----------------

.. automodule:: src.utils

.. autofunction:: createDataDictionary
.. autofunction:: createGlmDirName

.. autofunction:: getFuncVoxelDims
.. autofunction:: removeDummies
.. autofunction:: returnVolumeList
.. autofunction:: volumeSplicing
.. autofunction:: labelActivations

.. autofunction:: getContrastNb
.. autofunction:: getRegressorIdx

.. autofunction:: getDist2surf

.. autofunction:: computeMeanValueInMask
.. autofunction:: computeTsnr

.. autofunction:: setFields

.. autofunction:: validationInputFile


Print and error handling
------------------------

.. automodule:: src.messages

.. autofunction:: printToScreen
.. autofunction:: errorHandling

.. autofunction:: createUnorderedList

.. autofunction:: printAvailableContrasts

.. autofunction:: printWorkflowName
.. autofunction:: printBatchName

.. autofunction:: printCredits
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
