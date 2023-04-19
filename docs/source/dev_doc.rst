.. AUTOMATICALLY GENERATED

.. _dev_doc:

developer documentation
***********************


.. _workflows:

workflows
=========
.. _bidsChangeSuffix:
.. autofunction:: src.workflows.bidsChangeSuffix
.. _bidsCopyInputFolder:
.. autofunction:: src.workflows.bidsCopyInputFolder
.. _bidsInverseNormalize:
.. autofunction:: src.workflows.bidsInverseNormalize
.. _bidsQApreproc:
.. autofunction:: src.workflows.bidsQApreproc
.. _bidsRename:
.. autofunction:: src.workflows.bidsRename
.. _bidsReport:
.. autofunction:: src.workflows.bidsReport


.. _workflows roi:

workflows roi
=============
.. _bidsCreateROI:
.. autofunction:: src.workflows.roi.bidsCreateROI
.. _bidsRoiBasedGLM:
.. autofunction:: src.workflows.roi.bidsRoiBasedGLM


.. _workflows lesion:

workflows lesion
================
.. _bidsLesionAbnormalitiesDetection:
.. autofunction:: src.workflows.lesion.bidsLesionAbnormalitiesDetection
.. _bidsLesionOverlapMap:
.. autofunction:: src.workflows.lesion.bidsLesionOverlapMap
.. _bidsLesionSegmentation:
.. autofunction:: src.workflows.lesion.bidsLesionSegmentation


.. _workflows stats:

workflows stats
===============
.. _bidsConcatBetaTmaps:
.. autofunction:: src.workflows.stats.bidsConcatBetaTmaps
.. _bidsFFX:
.. autofunction:: src.workflows.stats.bidsFFX
.. _bidsModelSelection:
.. autofunction:: src.workflows.stats.bidsModelSelection
.. _bidsRFX:
.. autofunction:: src.workflows.stats.bidsRFX
.. _bidsResults:
.. autofunction:: src.workflows.stats.bidsResults


.. _workflows preproc:

workflows preproc
=================
.. _bidsCreateVDM:
.. autofunction:: src.workflows.preproc.bidsCreateVDM
.. _bidsGenerateT1map:
.. autofunction:: src.workflows.preproc.bidsGenerateT1map
.. _bidsRealignReslice:
.. autofunction:: src.workflows.preproc.bidsRealignReslice
.. _bidsRealignUnwarp:
.. autofunction:: src.workflows.preproc.bidsRealignUnwarp
.. _bidsRemoveDummies:
.. autofunction:: src.workflows.preproc.bidsRemoveDummies
.. _bidsResliceTpmToFunc:
.. autofunction:: src.workflows.preproc.bidsResliceTpmToFunc
.. _bidsSTC:
.. autofunction:: src.workflows.preproc.bidsSTC
.. _bidsSegmentSkullStrip:
.. autofunction:: src.workflows.preproc.bidsSegmentSkullStrip
.. _bidsSmoothing:
.. autofunction:: src.workflows.preproc.bidsSmoothing
.. _bidsSpatialPrepro:
.. autofunction:: src.workflows.preproc.bidsSpatialPrepro
.. _bidsWholeBrainFuncMask:
.. autofunction:: src.workflows.preproc.bidsWholeBrainFuncMask


.. _batches:

batches
=======
.. _saveMatlabBatch:
.. autofunction:: src.batches.saveMatlabBatch
.. _setBachRename:
.. autofunction:: src.batches.setBachRename
.. _setBatch3Dto4D:
.. autofunction:: src.batches.setBatch3Dto4D
.. _setBatchImageCalculation:
.. autofunction:: src.batches.setBatchImageCalculation
.. _setBatchMeanAnatAndMask:
.. autofunction:: src.batches.setBatchMeanAnatAndMask
.. _setBatchPrintFigure:
.. autofunction:: src.batches.setBatchPrintFigure
.. _setBatchReorient:
.. autofunction:: src.batches.setBatchReorient
.. _setBatchSelectAnat:
.. autofunction:: src.batches.setBatchSelectAnat


.. _batches lesion:

batches lesion
==============
.. _setBatchLesionAbnormalitiesDetection:
.. autofunction:: src.batches.lesion.setBatchLesionAbnormalitiesDetection
.. _setBatchLesionOverlapMap:
.. autofunction:: src.batches.lesion.setBatchLesionOverlapMap
.. _setBatchLesionSegmentation:
.. autofunction:: src.batches.lesion.setBatchLesionSegmentation


.. _batches stats:

batches stats
=============
.. _setBatchContrasts:
.. autofunction:: src.batches.stats.setBatchContrasts
.. _setBatchEstimateModel:
.. autofunction:: src.batches.stats.setBatchEstimateModel
.. _setBatchFactorialDesign:
.. autofunction:: src.batches.stats.setBatchFactorialDesign
.. _setBatchFactorialDesignImplicitMasking:
.. autofunction:: src.batches.stats.setBatchFactorialDesignImplicitMasking
.. _setBatchFatorialDesignGlobalCalcAndNorm:
.. autofunction:: src.batches.stats.setBatchFatorialDesignGlobalCalcAndNorm
.. _setBatchGroupLevelContrasts:
.. autofunction:: src.batches.stats.setBatchGroupLevelContrasts
.. _setBatchGroupLevelResults:
.. autofunction:: src.batches.stats.setBatchGroupLevelResults
.. _setBatchResults:
.. autofunction:: src.batches.stats.setBatchResults
.. _setBatchSubjectLevelContrasts:
.. autofunction:: src.batches.stats.setBatchSubjectLevelContrasts
.. _setBatchSubjectLevelGLMSpec:
.. autofunction:: src.batches.stats.setBatchSubjectLevelGLMSpec
.. _setBatchSubjectLevelResults:
.. autofunction:: src.batches.stats.setBatchSubjectLevelResults
.. _setBatchTwoSampleTTest:
.. autofunction:: src.batches.stats.setBatchTwoSampleTTest


.. _batches preproc:

batches preproc
===============
.. _setBatchComputeVDM:
.. autofunction:: src.batches.preproc.setBatchComputeVDM
.. _setBatchCoregistration:
.. autofunction:: src.batches.preproc.setBatchCoregistration
.. _setBatchCoregistrationFmap:
.. autofunction:: src.batches.preproc.setBatchCoregistrationFmap
.. _setBatchCoregistrationFuncToAnat:
.. autofunction:: src.batches.preproc.setBatchCoregistrationFuncToAnat
.. _setBatchCreateVDMs:
.. autofunction:: src.batches.preproc.setBatchCreateVDMs
.. _setBatchGenerateT1map:
.. autofunction:: src.batches.preproc.setBatchGenerateT1map
.. _setBatchInverseNormalize:
.. autofunction:: src.batches.preproc.setBatchInverseNormalize
.. _setBatchNormalizationSpatialPrepro:
.. autofunction:: src.batches.preproc.setBatchNormalizationSpatialPrepro
.. _setBatchNormalize:
.. autofunction:: src.batches.preproc.setBatchNormalize
.. _setBatchRealign:
.. autofunction:: src.batches.preproc.setBatchRealign
.. _setBatchRenameSegmentParameter:
.. autofunction:: src.batches.preproc.setBatchRenameSegmentParameter
.. _setBatchReslice:
.. autofunction:: src.batches.preproc.setBatchReslice
.. _setBatchSTC:
.. autofunction:: src.batches.preproc.setBatchSTC
.. _setBatchSaveCoregistrationMatrix:
.. autofunction:: src.batches.preproc.setBatchSaveCoregistrationMatrix
.. _setBatchSegmentation:
.. autofunction:: src.batches.preproc.setBatchSegmentation
.. _setBatchSkullStripping:
.. autofunction:: src.batches.preproc.setBatchSkullStripping
.. _setBatchSmoothConImages:
.. autofunction:: src.batches.preproc.setBatchSmoothConImages
.. _setBatchSmoothing:
.. autofunction:: src.batches.preproc.setBatchSmoothing
.. _setBatchSmoothingAnat:
.. autofunction:: src.batches.preproc.setBatchSmoothingAnat
.. _setBatchSmoothingFunc:
.. autofunction:: src.batches.preproc.setBatchSmoothingFunc


.. _IO:

IO
==
.. _addGitIgnore:
.. autofunction:: src.IO.addGitIgnore
.. _addLicense:
.. autofunction:: src.IO.addLicense
.. _addReadme:
.. autofunction:: src.IO.addReadme
.. _cleanCrash:
.. autofunction:: src.IO.cleanCrash
.. _convertRealignParamToTsv:
.. autofunction:: src.IO.convertRealignParamToTsv
.. _createDerivativeDir:
.. autofunction:: src.IO.createDerivativeDir
.. _getData:
.. autofunction:: src.IO.getData
.. _loadAndCheckOptions:
.. autofunction:: src.IO.loadAndCheckOptions
.. _onsetsMatToTsv:
.. autofunction:: src.IO.onsetsMatToTsv
.. _overwriteDir:
.. autofunction:: src.IO.overwriteDir
.. _regressorsMatToTsv:
.. autofunction:: src.IO.regressorsMatToTsv
.. _renameSegmentParameter:
.. autofunction:: src.IO.renameSegmentParameter
.. _renameUnwarpParameter:
.. autofunction:: src.IO.renameUnwarpParameter
.. _saveAndRunWorkflow:
.. autofunction:: src.IO.saveAndRunWorkflow
.. _saveOptions:
.. autofunction:: src.IO.saveOptions
.. _saveSpmScript:
.. autofunction:: src.IO.saveSpmScript
.. _unzipAndReturnsFullpathName:
.. autofunction:: src.IO.unzipAndReturnsFullpathName


.. _QA:

QA
==
.. _anatQA:
.. autofunction:: src.QA.anatQA
.. _censoring:
.. autofunction:: src.QA.censoring
.. _computeDesignEfficiency:
.. autofunction:: src.QA.computeDesignEfficiency
.. _computeFDandRMS:
.. autofunction:: src.QA.computeFDandRMS
.. _computeRobustOutliers:
.. autofunction:: src.QA.computeRobustOutliers
.. _mriqcQA:
.. autofunction:: src.QA.mriqcQA
.. _plotConfounds:
.. autofunction:: src.QA.plotConfounds
.. _plotEvents:
.. autofunction:: src.QA.plotEvents
.. _plotRoiTimeCourse:
.. autofunction:: src.QA.plotRoiTimeCourse
.. _realignQA:
.. autofunction:: src.QA.realignQA


.. _bids:

bids
====
.. _addStcToQuery:
.. autofunction:: src.bids.addStcToQuery
.. _buildIndividualSpaceRoiFilename:
.. autofunction:: src.bids.buildIndividualSpaceRoiFilename
.. _checkFmriprep:
.. autofunction:: src.bids.checkFmriprep
.. _fileFilterForBold:
.. autofunction:: src.bids.fileFilterForBold
.. _generatedBy:
.. autofunction:: src.bids.generatedBy
.. _getAnatFilename:
.. autofunction:: src.bids.getAnatFilename
.. _getAndCheckRepetitionTime:
.. autofunction:: src.bids.getAndCheckRepetitionTime
.. _getAndCheckSliceOrder:
.. autofunction:: src.bids.getAndCheckSliceOrder
.. _getBoldFilename:
.. autofunction:: src.bids.getBoldFilename
.. _getInfo:
.. autofunction:: src.bids.getInfo
.. _getMeanFuncFilename:
.. autofunction:: src.bids.getMeanFuncFilename
.. _getROIs:
.. autofunction:: src.bids.getROIs
.. _getSubjectList:
.. autofunction:: src.bids.getSubjectList
.. _getTpmFilename:
.. autofunction:: src.bids.getTpmFilename
.. _initBids:
.. autofunction:: src.bids.initBids
.. _isMni:
.. autofunction:: src.bids.isMni
.. _isSkullstripped:
.. autofunction:: src.bids.isSkullstripped
.. _removeEmptyQueryFields:
.. autofunction:: src.bids.removeEmptyQueryFields
.. _returnNameSkullstripOutput:
.. autofunction:: src.bids.returnNameSkullstripOutput
.. _roiGlmOutputName:
.. autofunction:: src.bids.roiGlmOutputName
.. _validate:
.. autofunction:: src.bids.validate


.. _bids_model:

bids_model
==========
.. _checkContrast:
.. autofunction:: src.bids_model.checkContrast
.. _checkGroupBy:
.. autofunction:: src.bids_model.checkGroupBy
.. _createDefaultStatsModel:
.. autofunction:: src.bids_model.createDefaultStatsModel
.. _getContrastsList:
.. autofunction:: src.bids_model.getContrastsList
.. _getContrastsListForFactorialDesign:
.. autofunction:: src.bids_model.getContrastsListForFactorialDesign
.. _getContrastsListFromSource:
.. autofunction:: src.bids_model.getContrastsListFromSource
.. _getDummyContrastsList:
.. autofunction:: src.bids_model.getDummyContrastsList
.. _getInclusiveMask:
.. autofunction:: src.bids_model.getInclusiveMask


.. _cli:

cli
===
.. _getOptionsFromCliArgument:
.. autofunction:: src.cli.getOptionsFromCliArgument


.. _defaults:

defaults
========
.. _ALI_my_defaults:
.. autofunction:: src.defaults.ALI_my_defaults
.. _MACS_my_defaults:
.. autofunction:: src.defaults.MACS_my_defaults
.. _checkOptions:
.. autofunction:: src.defaults.checkOptions
.. _defaultContrastsStructure:
.. autofunction:: src.defaults.defaultContrastsStructure
.. _defaultResultsStructure:
.. autofunction:: src.defaults.defaultResultsStructure
.. _getOptionsFromModel:
.. autofunction:: src.defaults.getOptionsFromModel
.. _mniToIxi:
.. autofunction:: src.defaults.mniToIxi
.. _setDirectories:
.. autofunction:: src.defaults.setDirectories
.. _setRenamingConfig:
.. autofunction:: src.defaults.setRenamingConfig
.. _set_spm_2_bids_defaults:
.. autofunction:: src.defaults.set_spm_2_bids_defaults
.. _spm_my_defaults:
.. autofunction:: src.defaults.spm_my_defaults


.. _infra:

infra
=====
.. _checkDependencies:
.. autofunction:: src.infra.checkDependencies
.. _checkToolbox:
.. autofunction:: src.infra.checkToolbox
.. _elapsedTime:
.. autofunction:: src.infra.elapsedTime
.. _getEnvInfo:
.. autofunction:: src.infra.getEnvInfo
.. _getRepoInfo:
.. autofunction:: src.infra.getRepoInfo
.. _getVersion:
.. autofunction:: src.infra.getVersion
.. _resizeAliMask:
.. autofunction:: src.infra.resizeAliMask
.. _returnBsmDocURL:
.. autofunction:: src.infra.returnBsmDocURL
.. _returnRepoURL:
.. autofunction:: src.infra.returnRepoURL
.. _returnRootDir:
.. autofunction:: src.infra.returnRootDir
.. _returnRtdURL:
.. autofunction:: src.infra.returnRtdURL
.. _setGraphicWindow:
.. autofunction:: src.infra.setGraphicWindow
.. _silenceOctaveWarning:
.. autofunction:: src.infra.silenceOctaveWarning


.. _messages:

messages
========
.. _bidspmHelp:
.. autofunction:: src.messages.bidspmHelp
.. _bugReport:
.. autofunction:: src.messages.bugReport
.. _deprecated:
.. autofunction:: src.messages.deprecated
.. _errorHandling:
.. autofunction:: src.messages.errorHandling
.. _logger:
.. autofunction:: src.messages.logger
.. _noRoiFound:
.. autofunction:: src.messages.noRoiFound
.. _noSPMmat:
.. autofunction:: src.messages.noSPMmat
.. _notImplemented:
.. autofunction:: src.messages.notImplemented
.. _pathToPrint:
.. autofunction:: src.messages.pathToPrint
.. _printAvailableContrasts:
.. autofunction:: src.messages.printAvailableContrasts
.. _printBatchName:
.. autofunction:: src.messages.printBatchName
.. _printCredits:
.. autofunction:: src.messages.printCredits
.. _printProcessingSubject:
.. autofunction:: src.messages.printProcessingSubject
.. _printToScreen:
.. autofunction:: src.messages.printToScreen
.. _printWorkflowName:
.. autofunction:: src.messages.printWorkflowName
.. _timeStamp:
.. autofunction:: src.messages.timeStamp


.. _preproc fieldmaps:

preproc fieldmaps
=================
.. _getBlipDirection:
.. autofunction:: src.preproc.fieldmaps.getBlipDirection
.. _getMetadataFromIntendedForFunc:
.. autofunction:: src.preproc.fieldmaps.getMetadataFromIntendedForFunc
.. _getTotalReadoutTime:
.. autofunction:: src.preproc.fieldmaps.getTotalReadoutTime
.. _getVdmFile:
.. autofunction:: src.preproc.fieldmaps.getVdmFile


.. _preproc utils:

preproc utils
=============
.. _createPialSurface:
.. autofunction:: src.preproc.utils.createPialSurface
.. _getAcquisitionTime:
.. autofunction:: src.preproc.utils.getAcquisitionTime
.. _removeDummies:
.. autofunction:: src.preproc.utils.removeDummies
.. _segmentationAlreadyDone:
.. autofunction:: src.preproc.utils.segmentationAlreadyDone
.. _skullstrippingAlreadyDone:
.. autofunction:: src.preproc.utils.skullstrippingAlreadyDone


.. _reports:

reports
=======
.. _boilerplate:
.. autofunction:: src.reports.boilerplate
.. _copyFigures:
.. autofunction:: src.reports.copyFigures
.. _copyGraphWindownOutput:
.. autofunction:: src.reports.copyGraphWindownOutput


.. _stats results:

stats results
=============
.. _convertPvalueToString:
.. autofunction:: src.stats.results.convertPvalueToString
.. _defaultOuputNameStruct:
.. autofunction:: src.stats.results.defaultOuputNameStruct
.. _returnName:
.. autofunction:: src.stats.results.returnName
.. _setMontage:
.. autofunction:: src.stats.results.setMontage
.. _setNidm:
.. autofunction:: src.stats.results.setNidm


.. _stats subject_level:

stats subject_level
===================
.. _allRunsHaveSameNbRegressors:
.. autofunction:: src.stats.subject_level.allRunsHaveSameNbRegressors
.. _appendContrast:
.. autofunction:: src.stats.subject_level.appendContrast
.. _checkRegressorName:
.. autofunction:: src.stats.subject_level.checkRegressorName
.. _convertOnsetTsvToMat:
.. autofunction:: src.stats.subject_level.convertOnsetTsvToMat
.. _createAndReturnCounfoundMatFile:
.. autofunction:: src.stats.subject_level.createAndReturnCounfoundMatFile
.. _createAndReturnOnsetFile:
.. autofunction:: src.stats.subject_level.createAndReturnOnsetFile
.. _createConfounds:
.. autofunction:: src.stats.subject_level.createConfounds
.. _deleteResidualImages:
.. autofunction:: src.stats.subject_level.deleteResidualImages
.. _getBoldFilenameForFFX:
.. autofunction:: src.stats.subject_level.getBoldFilenameForFFX
.. _getConfoundsRegressorFilename:
.. autofunction:: src.stats.subject_level.getConfoundsRegressorFilename
.. _getEventSpecificationRoiGlm:
.. autofunction:: src.stats.subject_level.getEventSpecificationRoiGlm
.. _getEventsData:
.. autofunction:: src.stats.subject_level.getEventsData
.. _getFFXdir:
.. autofunction:: src.stats.subject_level.getFFXdir
.. _getSessionForRegressorNb:
.. autofunction:: src.stats.subject_level.getSessionForRegressorNb
.. _newContrast:
.. autofunction:: src.stats.subject_level.newContrast
.. _orderAndPadCounfoundMatFile:
.. autofunction:: src.stats.subject_level.orderAndPadCounfoundMatFile
.. _removeIntercept:
.. autofunction:: src.stats.subject_level.removeIntercept
.. _reorderCounfounds:
.. autofunction:: src.stats.subject_level.reorderCounfounds
.. _saveRoiGlmSummaryTable:
.. autofunction:: src.stats.subject_level.saveRoiGlmSummaryTable
.. _selectConfoundsByVarianceExplained:
.. autofunction:: src.stats.subject_level.selectConfoundsByVarianceExplained
.. _specifyContrasts:
.. autofunction:: src.stats.subject_level.specifyContrasts
.. _specifyDummyContrasts:
.. autofunction:: src.stats.subject_level.specifyDummyContrasts
.. _specifySubLvlContrasts:
.. autofunction:: src.stats.subject_level.specifySubLvlContrasts


.. _stats group_level:

stats group_level
=================
.. _findSubjectConImage:
.. autofunction:: src.stats.group_level.findSubjectConImage
.. _getRFXdir:
.. autofunction:: src.stats.group_level.getRFXdir
.. _groupLevelGlmType:
.. autofunction:: src.stats.group_level.groupLevelGlmType


.. _stats utils:

stats utils
===========
.. _createGlmDirName:
.. autofunction:: src.stats.utils.createGlmDirName
.. _designMatrixFigureName:
.. autofunction:: src.stats.utils.designMatrixFigureName
.. _fillInResultStructure:
.. autofunction:: src.stats.utils.fillInResultStructure
.. _getContrastNb:
.. autofunction:: src.stats.utils.getContrastNb
.. _getRegressorIdx:
.. autofunction:: src.stats.utils.getRegressorIdx
.. _isTtest:
.. autofunction:: src.stats.utils.isTtest
.. _labelActivations:
.. autofunction:: src.stats.utils.labelActivations
.. _returnContrastImageFile:
.. autofunction:: src.stats.utils.returnContrastImageFile


.. _utils:

utils
=====
.. _checkMaskOrUnderlay:
.. autofunction:: src.utils.checkMaskOrUnderlay
.. _cleanUpWorkflow:
.. autofunction:: src.utils.cleanUpWorkflow
.. _computeMeanValueInMask:
.. autofunction:: src.utils.computeMeanValueInMask
.. _computeTsnr:
.. autofunction:: src.utils.computeTsnr
.. _createDataDictionary:
.. autofunction:: src.utils.createDataDictionary
.. _deregexify:
.. autofunction:: src.utils.deregexify
.. _getDist2surf:
.. autofunction:: src.utils.getDist2surf
.. _getFuncVoxelDims:
.. autofunction:: src.utils.getFuncVoxelDims
.. _isZipped:
.. autofunction:: src.utils.isZipped
.. _regexify:
.. autofunction:: src.utils.regexify
.. _renamePng:
.. autofunction:: src.utils.renamePng
.. _returnBatchFileName:
.. autofunction:: src.utils.returnBatchFileName
.. _returnDependency:
.. autofunction:: src.utils.returnDependency
.. _returnVolumeList:
.. autofunction:: src.utils.returnVolumeList
.. _setFields:
.. autofunction:: src.utils.setFields
.. _setUpWorkflow:
.. autofunction:: src.utils.setUpWorkflow
.. _unfoldStruct:
.. autofunction:: src.utils.unfoldStruct
.. _validationInputFile:
.. autofunction:: src.utils.validationInputFile
.. _volumeSplicing:
.. autofunction:: src.utils.volumeSplicing
