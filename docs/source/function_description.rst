Function description
********************
  
List of functions in the ``src`` folder.  

----

.. automodule:: src 

.. autofunction:: getAnatFilename
.. autofunction:: getBoldFilename
.. autofunction:: getData
.. autofunction:: getFuncVoxelDims
.. autofunction:: getInfo
.. autofunction:: getMeanFuncFilename
.. autofunction:: getPrefix
.. autofunction:: getRealignParamFile
.. autofunction:: getSliceOrder
.. autofunction:: getSpecificSubjects
.. autofunction:: setDerivativesDir
.. autofunction:: unzipImgAndReturnsFullpathName

Subject level model
===================

.. automodule:: src.subject_level

.. autofunction:: concatBetaImgTmaps
.. autofunction:: convertOnsetTsvToMat
.. autofunction:: createAndReturnOnsetFile
.. autofunction:: deleteResidualImages
.. autofunction:: getBoldFilenameForFFX
.. autofunction:: getFFXdir
.. autofunction:: specifyContrasts

Group level model
=================

.. automodule:: src.group_level

.. autofunction:: getGrpLevelContrastToCompute
.. autofunction:: getRFXdir


fieldmaps
=========

.. automodule:: src.fieldmaps

.. autofunction:: getBlipDirection
.. autofunction:: getMetadataFromIntendedForFunc
.. autofunction:: getTotalReadoutTime
.. autofunction:: getVdmFile

Utilities
=========

Utility functions

----

.. automodule:: src.utils 

.. autofunction:: checkDependencies
.. autofunction:: createDataDictionary
.. autofunction:: getEnvInfo
.. autofunction:: getVersion
.. autofunction:: isOctave
.. autofunction:: loadAndCheckOptions
.. autofunction:: printCredits
.. autofunction:: printProcessingRun
.. autofunction:: printProcessingSubject
.. autofunction:: saveMatlabBatch
.. autofunction:: saveOptions
.. autofunction:: setDefaultFields
.. autofunction:: validationInputFile
