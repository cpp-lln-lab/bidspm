.. AUTOMATICALLY GENERATED

.. _dev_doc:

developer documentation
***********************


.. _workflows stats:

workflows stats
===============
.. _bidsModelSelection:
.. autofunction:: src.workflows.stats.bidsModelSelection
.. _bidsFFX:
.. autofunction:: src.workflows.stats.bidsFFX
.. _bidsConcatBetaTmaps:
.. autofunction:: src.workflows.stats.bidsConcatBetaTmaps
.. _bidsRFX:
.. autofunction:: src.workflows.stats.bidsRFX
.. _bidsResults:
.. autofunction:: src.workflows.stats.bidsResults


.. _workflows preproc:

workflows preproc
=================
.. _bidsGenerateT1map:
.. autofunction:: src.workflows.preproc.bidsGenerateT1map
.. _bidsCreateVDM:
.. autofunction:: src.workflows.preproc.bidsCreateVDM
.. _bidsResliceTpmToFunc:
.. autofunction:: src.workflows.preproc.bidsResliceTpmToFunc
.. _bidsRealignUnwarp:
.. autofunction:: src.workflows.preproc.bidsRealignUnwarp
.. _bidsSpatialPrepro:
.. autofunction:: src.workflows.preproc.bidsSpatialPrepro
.. _bidsWholeBrainFuncMask:
.. autofunction:: src.workflows.preproc.bidsWholeBrainFuncMask
.. _bidsRemoveDummies:
.. autofunction:: src.workflows.preproc.bidsRemoveDummies
.. _bidsSmoothing:
.. autofunction:: src.workflows.preproc.bidsSmoothing
.. _bidsRealignReslice:
.. autofunction:: src.workflows.preproc.bidsRealignReslice
.. _bidsSegmentSkullStrip:
.. autofunction:: src.workflows.preproc.bidsSegmentSkullStrip
.. _bidsSTC:
.. autofunction:: src.workflows.preproc.bidsSTC


.. _workflows lesion:

workflows lesion
================
.. _bidsLesionSegmentation:
.. autofunction:: src.workflows.lesion.bidsLesionSegmentation
.. _bidsLesionAbnormalitiesDetection:
.. autofunction:: src.workflows.lesion.bidsLesionAbnormalitiesDetection
.. _bidsLesionOverlapMap:
.. autofunction:: src.workflows.lesion.bidsLesionOverlapMap


.. _workflows roi:

workflows roi
=============
.. _bidsCreateROI:
.. autofunction:: src.workflows.roi.bidsCreateROI
.. _bidsRoiBasedGLM:
.. autofunction:: src.workflows.roi.bidsRoiBasedGLM


.. _workflows:

workflows
=========
.. _bidsRsHrf:
.. autofunction:: src.workflows.bidsRsHrf
.. _bidsChangeSuffix:
.. autofunction:: src.workflows.bidsChangeSuffix
.. _bidsReport:
.. autofunction:: src.workflows.bidsReport
.. _bidsCopyInputFolder:
.. autofunction:: src.workflows.bidsCopyInputFolder
.. _bidsRename:
.. autofunction:: src.workflows.bidsRename
.. _bidsInverseNormalize:
.. autofunction:: src.workflows.bidsInverseNormalize


.. _batches stats:

batches stats
=============
.. _setBatchResults:
.. autofunction:: src.batches.stats.setBatchResults
.. _setBatchSubjectLevelGLMSpec:
.. autofunction:: src.batches.stats.setBatchSubjectLevelGLMSpec
.. _setBatchSubjectLevelContrasts:
.. autofunction:: src.batches.stats.setBatchSubjectLevelContrasts
.. _setBatchSubjectLevelResults:
.. autofunction:: src.batches.stats.setBatchSubjectLevelResults
.. _setBatchFatorialDesignGlobalCalcAndNorm:
.. autofunction:: src.batches.stats.setBatchFatorialDesignGlobalCalcAndNorm
.. _setBatchFactorialDesign:
.. autofunction:: src.batches.stats.setBatchFactorialDesign
.. _setBatchEstimateModel:
.. autofunction:: src.batches.stats.setBatchEstimateModel
.. _setBatchFactorialDesignImplicitMasking:
.. autofunction:: src.batches.stats.setBatchFactorialDesignImplicitMasking
.. _setBatchGroupLevelResults:
.. autofunction:: src.batches.stats.setBatchGroupLevelResults
.. _setBatchContrasts:
.. autofunction:: src.batches.stats.setBatchContrasts
.. _setBatchGroupLevelContrasts:
.. autofunction:: src.batches.stats.setBatchGroupLevelContrasts
.. _setBatchTwoSampleTTest:
.. autofunction:: src.batches.stats.setBatchTwoSampleTTest


.. _batches preproc:

batches preproc
===============
.. _setBatchRealign:
.. autofunction:: src.batches.preproc.setBatchRealign
.. _setBatchSmoothingAnat:
.. autofunction:: src.batches.preproc.setBatchSmoothingAnat
.. _setBatchCoregistrationFmap:
.. autofunction:: src.batches.preproc.setBatchCoregistrationFmap
.. _setBatchRenameSegmentParameter:
.. autofunction:: src.batches.preproc.setBatchRenameSegmentParameter
.. _setBatchInverseNormalize:
.. autofunction:: src.batches.preproc.setBatchInverseNormalize
.. _setBatchSTC:
.. autofunction:: src.batches.preproc.setBatchSTC
.. _setBatchNormalizationSpatialPrepro:
.. autofunction:: src.batches.preproc.setBatchNormalizationSpatialPrepro
.. _setBatchCoregistrationFuncToAnat:
.. autofunction:: src.batches.preproc.setBatchCoregistrationFuncToAnat
.. _setBatchCreateVDMs:
.. autofunction:: src.batches.preproc.setBatchCreateVDMs
.. _setBatchSkullStripping:
.. autofunction:: src.batches.preproc.setBatchSkullStripping
.. _setBatchNormalize:
.. autofunction:: src.batches.preproc.setBatchNormalize
.. _setBatchSaveCoregistrationMatrix:
.. autofunction:: src.batches.preproc.setBatchSaveCoregistrationMatrix
.. _setBatchCoregistration:
.. autofunction:: src.batches.preproc.setBatchCoregistration
.. _setBatchReslice:
.. autofunction:: src.batches.preproc.setBatchReslice
.. _setBatchSmoothing:
.. autofunction:: src.batches.preproc.setBatchSmoothing
.. _setBatchComputeVDM:
.. autofunction:: src.batches.preproc.setBatchComputeVDM
.. _setBatchSmoothingFunc:
.. autofunction:: src.batches.preproc.setBatchSmoothingFunc
.. _setBatchSmoothConImages:
.. autofunction:: src.batches.preproc.setBatchSmoothConImages
.. _setBatchGenerateT1map:
.. autofunction:: src.batches.preproc.setBatchGenerateT1map
.. _setBatchSegmentation:
.. autofunction:: src.batches.preproc.setBatchSegmentation


.. _batches lesion:

batches lesion
==============
.. _setBatchLesionOverlapMap:
.. autofunction:: src.batches.lesion.setBatchLesionOverlapMap
.. _setBatchLesionAbnormalitiesDetection:
.. autofunction:: src.batches.lesion.setBatchLesionAbnormalitiesDetection
.. _setBatchLesionSegmentation:
.. autofunction:: src.batches.lesion.setBatchLesionSegmentation


.. _batches:

batches
=======
.. _setBatchSelectAnat:
.. autofunction:: src.batches.setBatchSelectAnat
.. _saveMatlabBatch:
.. autofunction:: src.batches.saveMatlabBatch
.. _setBatchReorient:
.. autofunction:: src.batches.setBatchReorient
.. _setBachRename:
.. autofunction:: src.batches.setBachRename
.. _setBatchMeanAnatAndMask:
.. autofunction:: src.batches.setBatchMeanAnatAndMask
.. _setBatchPrintFigure:
.. autofunction:: src.batches.setBatchPrintFigure
.. _setBatchImageCalculation:
.. autofunction:: src.batches.setBatchImageCalculation
.. _setBatchRsHRF:
.. autofunction:: src.batches.setBatchRsHRF
.. _setBatch3Dto4D:
.. autofunction:: src.batches.setBatch3Dto4D


.. _reports:

reports
=======
.. _copyGraphWindownOutput:
.. autofunction:: src.reports.copyGraphWindownOutput
.. _copyFigures:
.. autofunction:: src.reports.copyFigures
.. _boilerplate:
.. autofunction:: src.reports.boilerplate


.. _infra:

infra
=====
.. _checkToolbox:
.. autofunction:: src.infra.checkToolbox
.. _returnBsmDocURL:
.. autofunction:: src.infra.returnBsmDocURL
.. _getRepoInfo:
.. autofunction:: src.infra.getRepoInfo
.. _elapsedTime:
.. autofunction:: src.infra.elapsedTime
.. _returnRepoURL:
.. autofunction:: src.infra.returnRepoURL
.. _setGraphicWindow:
.. autofunction:: src.infra.setGraphicWindow
.. _getEnvInfo:
.. autofunction:: src.infra.getEnvInfo
.. _isGithubCi:
.. autofunction:: src.infra.isGithubCi
.. _checkDependencies:
.. autofunction:: src.infra.checkDependencies
.. _resizeAliMask:
.. autofunction:: src.infra.resizeAliMask
.. _returnRootDir:
.. autofunction:: src.infra.returnRootDir
.. _getVersion:
.. autofunction:: src.infra.getVersion
.. _isOctave:
.. autofunction:: src.infra.isOctave
.. _returnRtdURL:
.. autofunction:: src.infra.returnRtdURL


.. _QA:

QA
==
.. _functionalQA:
.. autofunction:: src.QA.functionalQA
.. _anatomicalQA:
.. autofunction:: src.QA.anatomicalQA
.. _plotEvents:
.. autofunction:: src.QA.plotEvents
.. _computeDesignEfficiency:
.. autofunction:: src.QA.computeDesignEfficiency
.. _mriqcQA:
.. autofunction:: src.QA.mriqcQA
.. _plotRoiTimeCourse:
.. autofunction:: src.QA.plotRoiTimeCourse


.. _bids_model:

bids_model
==========
.. _createDefaultStatsModel:
.. autofunction:: src.bids_model.createDefaultStatsModel
.. _getContrastsListForFactorialDesign:
.. autofunction:: src.bids_model.getContrastsListForFactorialDesign
.. _getContrastsListFromSource:
.. autofunction:: src.bids_model.getContrastsListFromSource
.. _checkContrast:
.. autofunction:: src.bids_model.checkContrast
.. _getDummyContrastsList:
.. autofunction:: src.bids_model.getDummyContrastsList
.. _checkGroupBy:
.. autofunction:: src.bids_model.checkGroupBy
.. _getContrastsList:
.. autofunction:: src.bids_model.getContrastsList
.. _getInclusiveMask:
.. autofunction:: src.bids_model.getInclusiveMask


.. _cli:

cli
===
.. _getOptionsFromCliArgument:
.. autofunction:: src.cli.getOptionsFromCliArgument


.. _stats:

stats
=====


.. _defaults:

defaults
========
.. _setRenamingConfig:
.. autofunction:: src.defaults.setRenamingConfig
.. _rsHRF_my_defaults:
.. autofunction:: src.defaults.rsHRF_my_defaults
.. _setDirectories:
.. autofunction:: src.defaults.setDirectories
.. _mniToIxi:
.. autofunction:: src.defaults.mniToIxi
.. _getOptionsFromModel:
.. autofunction:: src.defaults.getOptionsFromModel
.. _set_spm_2_bids_defaults:
.. autofunction:: src.defaults.set_spm_2_bids_defaults
.. _ALI_my_defaults:
.. autofunction:: src.defaults.ALI_my_defaults
.. _MACS_my_defaults:
.. autofunction:: src.defaults.MACS_my_defaults
.. _checkOptions:
.. autofunction:: src.defaults.checkOptions
.. _defaultContrastsStructure:
.. autofunction:: src.defaults.defaultContrastsStructure
.. _spm_my_defaults:
.. autofunction:: src.defaults.spm_my_defaults
.. _defaultResultsStructure:
.. autofunction:: src.defaults.defaultResultsStructure


.. _utils:

utils
=====
.. _isZipped:
.. autofunction:: src.utils.isZipped
.. _renamePng:
.. autofunction:: src.utils.renamePng
.. _returnBatchFileName:
.. autofunction:: src.utils.returnBatchFileName
.. _volumeSplicing:
.. autofunction:: src.utils.volumeSplicing
.. _computeTsnr:
.. autofunction:: src.utils.computeTsnr
.. _checkMaskOrUnderlay:
.. autofunction:: src.utils.checkMaskOrUnderlay
.. _setUpWorkflow:
.. autofunction:: src.utils.setUpWorkflow
.. _deregexify:
.. autofunction:: src.utils.deregexify
.. _cleanUpWorkflow:
.. autofunction:: src.utils.cleanUpWorkflow
.. _createDataDictionary:
.. autofunction:: src.utils.createDataDictionary
.. _isTtest:
.. autofunction:: src.utils.isTtest
.. _regexify:
.. autofunction:: src.utils.regexify
.. _setFields:
.. autofunction:: src.utils.setFields
.. _computeMeanValueInMask:
.. autofunction:: src.utils.computeMeanValueInMask
.. _getFuncVoxelDims:
.. autofunction:: src.utils.getFuncVoxelDims
.. _returnDependency:
.. autofunction:: src.utils.returnDependency
.. _getDist2surf:
.. autofunction:: src.utils.getDist2surf
.. _returnVolumeList:
.. autofunction:: src.utils.returnVolumeList
.. _validationInputFile:
.. autofunction:: src.utils.validationInputFile
.. _unfoldStruct:
.. autofunction:: src.utils.unfoldStruct


.. _bids:

bids
====
.. _getAndCheckSliceOrder:
.. autofunction:: src.bids.getAndCheckSliceOrder
.. _generatedBy:
.. autofunction:: src.bids.generatedBy
.. _getTpmFilename:
.. autofunction:: src.bids.getTpmFilename
.. _addStcToQuery:
.. autofunction:: src.bids.addStcToQuery
.. _validate:
.. autofunction:: src.bids.validate
.. _getROIs:
.. autofunction:: src.bids.getROIs
.. _fileFilterForBold:
.. autofunction:: src.bids.fileFilterForBold
.. _roiGlmOutputName:
.. autofunction:: src.bids.roiGlmOutputName
.. _removeEmptyQueryFields:
.. autofunction:: src.bids.removeEmptyQueryFields
.. _buildIndividualSpaceRoiFilename:
.. autofunction:: src.bids.buildIndividualSpaceRoiFilename
.. _getBoldFilename:
.. autofunction:: src.bids.getBoldFilename
.. _getInfo:
.. autofunction:: src.bids.getInfo
.. _isSkullstripped:
.. autofunction:: src.bids.isSkullstripped
.. _isMni:
.. autofunction:: src.bids.isMni
.. _getMeanFuncFilename:
.. autofunction:: src.bids.getMeanFuncFilename
.. _initBids:
.. autofunction:: src.bids.initBids
.. _getAnatFilename:
.. autofunction:: src.bids.getAnatFilename
.. _getSubjectList:
.. autofunction:: src.bids.getSubjectList
.. _returnNameSkullstripOutput:
.. autofunction:: src.bids.returnNameSkullstripOutput
.. _checkFmriprep:
.. autofunction:: src.bids.checkFmriprep
.. _getAndCheckRepetitionTime:
.. autofunction:: src.bids.getAndCheckRepetitionTime


.. _IO:

IO
==
.. _createDerivativeDir:
.. autofunction:: src.IO.createDerivativeDir
.. _renameUnwarpParameter:
.. autofunction:: src.IO.renameUnwarpParameter
.. _saveOptions:
.. autofunction:: src.IO.saveOptions
.. _onsetsMatToTsv:
.. autofunction:: src.IO.onsetsMatToTsv
.. _getData:
.. autofunction:: src.IO.getData
.. _unzipAndReturnsFullpathName:
.. autofunction:: src.IO.unzipAndReturnsFullpathName
.. _cleanCrash:
.. autofunction:: src.IO.cleanCrash
.. _regressorsMatToTsv:
.. autofunction:: src.IO.regressorsMatToTsv
.. _overwriteDir:
.. autofunction:: src.IO.overwriteDir
.. _saveSpmScript:
.. autofunction:: src.IO.saveSpmScript
.. _loadAndCheckOptions:
.. autofunction:: src.IO.loadAndCheckOptions
.. _saveAndRunWorkflow:
.. autofunction:: src.IO.saveAndRunWorkflow
.. _renameSegmentParameter:
.. autofunction:: src.IO.renameSegmentParameter


.. _messages:

messages
========
.. _pathToPrint:
.. autofunction:: src.messages.pathToPrint
.. _printBatchName:
.. autofunction:: src.messages.printBatchName
.. _noRoiFound:
.. autofunction:: src.messages.noRoiFound
.. _printToScreen:
.. autofunction:: src.messages.printToScreen
.. _bidspmHelp:
.. autofunction:: src.messages.bidspmHelp
.. _bugReport:
.. autofunction:: src.messages.bugReport
.. _printProcessingSubject:
.. autofunction:: src.messages.printProcessingSubject
.. _createUnorderedList:
.. autofunction:: src.messages.createUnorderedList
.. _printCredits:
.. autofunction:: src.messages.printCredits
.. _errorHandling:
.. autofunction:: src.messages.errorHandling
.. _noSPMmat:
.. autofunction:: src.messages.noSPMmat
.. _timeStamp:
.. autofunction:: src.messages.timeStamp
.. _notImplemented:
.. autofunction:: src.messages.notImplemented
.. _printWorkflowName:
.. autofunction:: src.messages.printWorkflowName
.. _logger:
.. autofunction:: src.messages.logger
.. _printAvailableContrasts:
.. autofunction:: src.messages.printAvailableContrasts


.. _preproc:

preproc
=======
