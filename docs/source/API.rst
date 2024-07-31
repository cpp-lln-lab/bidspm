.. _dev_doc:

API
***

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


.. AUTOMATICALLY GENERATED

workflows
=========
.. autofunction:: src.workflows.bidsChangeSuffix
.. autofunction:: src.workflows.bidsCheckVoxelSize
.. autofunction:: src.workflows.bidsCopyInputFolder
.. autofunction:: src.workflows.bidsInverseNormalize
.. autofunction:: src.workflows.bidsQAbidspm
.. autofunction:: src.workflows.bidsRename
.. autofunction:: src.workflows.bidsReport

roi
---
.. autofunction:: src.workflows.roi.bidsCreateROI
.. autofunction:: src.workflows.roi.bidsRoiBasedGLM

lesion
------
.. autofunction:: src.workflows.lesion.bidsLesionAbnormalitiesDetection
.. autofunction:: src.workflows.lesion.bidsLesionOverlapMap
.. autofunction:: src.workflows.lesion.bidsLesionSegmentation

stats
-----
.. autofunction:: src.workflows.stats.bidsConcatBetaTmaps
.. autofunction:: src.workflows.stats.bidsFFX
.. autofunction:: src.workflows.stats.bidsModelSelection
.. autofunction:: src.workflows.stats.bidsRFX
.. autofunction:: src.workflows.stats.bidsResults
.. autofunction:: src.workflows.stats.bidsSmoothContrasts

preproc
-------
.. autofunction:: src.workflows.preproc.bidsCreateVDM
.. autofunction:: src.workflows.preproc.bidsGenerateT1map
.. autofunction:: src.workflows.preproc.bidsRealignReslice
.. autofunction:: src.workflows.preproc.bidsRealignUnwarp
.. autofunction:: src.workflows.preproc.bidsRemoveDummies
.. autofunction:: src.workflows.preproc.bidsResliceTpmToFunc
.. autofunction:: src.workflows.preproc.bidsSTC
.. autofunction:: src.workflows.preproc.bidsSegmentSkullStrip
.. autofunction:: src.workflows.preproc.bidsSmoothing
.. autofunction:: src.workflows.preproc.bidsSpatialPrepro
.. autofunction:: src.workflows.preproc.bidsWholeBrainFuncMask

batches
=======
.. autofunction:: src.batches.saveMatlabBatch
.. autofunction:: src.batches.setBachRename
.. autofunction:: src.batches.setBatch3Dto4D
.. autofunction:: src.batches.setBatchImageCalculation
.. autofunction:: src.batches.setBatchMeanAnatAndMask
.. autofunction:: src.batches.setBatchPrintFigure
.. autofunction:: src.batches.setBatchReorient
.. autofunction:: src.batches.setBatchSelectAnat

lesion
------
.. autofunction:: src.batches.lesion.setBatchLesionAbnormalitiesDetection
.. autofunction:: src.batches.lesion.setBatchLesionOverlapMap
.. autofunction:: src.batches.lesion.setBatchLesionSegmentation

stats
-----
.. autofunction:: src.batches.stats.setBatchContrasts
.. autofunction:: src.batches.stats.setBatchEstimateModel
.. autofunction:: src.batches.stats.setBatchFactorialDesign
.. autofunction:: src.batches.stats.setBatchFactorialDesignGlobalCalcAndNorm
.. autofunction:: src.batches.stats.setBatchFactorialDesignImplicitMasking
.. autofunction:: src.batches.stats.setBatchGoodnessOfFit
.. autofunction:: src.batches.stats.setBatchGroupLevelContrasts
.. autofunction:: src.batches.stats.setBatchGroupLevelResults
.. autofunction:: src.batches.stats.setBatchInformationCriteria
.. autofunction:: src.batches.stats.setBatchResults
.. autofunction:: src.batches.stats.setBatchSubjectLevelContrasts
.. autofunction:: src.batches.stats.setBatchSubjectLevelGLMSpec
.. autofunction:: src.batches.stats.setBatchSubjectLevelResults
.. autofunction:: src.batches.stats.setBatchTwoSampleTTest

preproc
-------
.. autofunction:: src.batches.preproc.setBatchComputeVDM
.. autofunction:: src.batches.preproc.setBatchCoregistration
.. autofunction:: src.batches.preproc.setBatchCoregistrationFmap
.. autofunction:: src.batches.preproc.setBatchCoregistrationFuncToAnat
.. autofunction:: src.batches.preproc.setBatchCreateVDMs
.. autofunction:: src.batches.preproc.setBatchGenerateT1map
.. autofunction:: src.batches.preproc.setBatchInverseNormalize
.. autofunction:: src.batches.preproc.setBatchNormalizationSpatialPrepro
.. autofunction:: src.batches.preproc.setBatchNormalize
.. autofunction:: src.batches.preproc.setBatchRealign
.. autofunction:: src.batches.preproc.setBatchRenameSegmentParameter
.. autofunction:: src.batches.preproc.setBatchReslice
.. autofunction:: src.batches.preproc.setBatchSTC
.. autofunction:: src.batches.preproc.setBatchSaveCoregistrationMatrix
.. autofunction:: src.batches.preproc.setBatchSegmentation
.. autofunction:: src.batches.preproc.setBatchSkullStripping
.. autofunction:: src.batches.preproc.setBatchSmoothConImages
.. autofunction:: src.batches.preproc.setBatchSmoothing
.. autofunction:: src.batches.preproc.setBatchSmoothingAnat
.. autofunction:: src.batches.preproc.setBatchSmoothingFunc

IO
==
.. autofunction:: src.IO.addGitIgnore
.. autofunction:: src.IO.addLicense
.. autofunction:: src.IO.addReadme
.. autofunction:: src.IO.cleanCrash
.. autofunction:: src.IO.convertRealignParamToTsv
.. autofunction:: src.IO.createDerivativeDir
.. autofunction:: src.IO.getData
.. autofunction:: src.IO.loadAndCheckOptions
.. autofunction:: src.IO.onsetsMatToTsv
.. autofunction:: src.IO.overwriteDir
.. autofunction:: src.IO.regressorsMatToTsv
.. autofunction:: src.IO.renameSegmentParameter
.. autofunction:: src.IO.renameUnwarpParameter
.. autofunction:: src.IO.saveAndRunWorkflow
.. autofunction:: src.IO.saveOptions
.. autofunction:: src.IO.saveSpmScript
.. autofunction:: src.IO.unzipAndReturnsFullpathName

QA
==
.. autofunction:: src.QA.anatQA
.. autofunction:: src.QA.censoring
.. autofunction:: src.QA.compileScrubbingStats
.. autofunction:: src.QA.computeDesignEfficiency
.. autofunction:: src.QA.computeFDandRMS
.. autofunction:: src.QA.computeRobustOutliers
.. autofunction:: src.QA.createDesignMatrix
.. autofunction:: src.QA.mriqcQA
.. autofunction:: src.QA.plotConfounds
.. autofunction:: src.QA.plotEvents
.. autofunction:: src.QA.plotRoiTimeCourse
.. autofunction:: src.QA.realignQA

bids
====
.. autofunction:: src.bids.addStcToQuery
.. autofunction:: src.bids.buildIndividualSpaceRoiFilename
.. autofunction:: src.bids.checkFmriprep
.. autofunction:: src.bids.fileFilterForBold
.. autofunction:: src.bids.generatedBy
.. autofunction:: src.bids.getAnatFilename
.. autofunction:: src.bids.getAndCheckRepetitionTime
.. autofunction:: src.bids.getAndCheckSliceOrder
.. autofunction:: src.bids.getAvailableGroups
.. autofunction:: src.bids.getBoldFilename
.. autofunction:: src.bids.getInfo
.. autofunction:: src.bids.getMeanFuncFilename
.. autofunction:: src.bids.getROIs
.. autofunction:: src.bids.getSubjectList
.. autofunction:: src.bids.getTpmFilename
.. autofunction:: src.bids.initBids
.. autofunction:: src.bids.removeEmptyQueryFields
.. autofunction:: src.bids.returnNameSkullstripOutput
.. autofunction:: src.bids.roiGlmOutputName
.. autofunction:: src.bids.validate

bids_model
==========
.. autofunction:: src.bids_model.checkContrast
.. autofunction:: src.bids_model.createDefaultStatsModel
.. autofunction:: src.bids_model.createModelFamilies
.. autofunction:: src.bids_model.getContrastsFromParentNode
.. autofunction:: src.bids_model.getContrastsList
.. autofunction:: src.bids_model.getContrastsListForFactorialDesign
.. autofunction:: src.bids_model.getDummyContrastFromParentNode
.. autofunction:: src.bids_model.getDummyContrastsList
.. autofunction:: src.bids_model.getInclusiveMask

bidspm
======

data
----

cli
===
.. autofunction:: src.cli.baseInputParser
.. autofunction:: src.cli.cliBayesModel
.. autofunction:: src.cli.cliCopy
.. autofunction:: src.cli.cliCreateRoi
.. autofunction:: src.cli.cliDefaultModel
.. autofunction:: src.cli.cliPreprocess
.. autofunction:: src.cli.cliSmooth
.. autofunction:: src.cli.cliStats
.. autofunction:: src.cli.getBidsFilterFile
.. autofunction:: src.cli.getOptionsFromCliArgument
.. autofunction:: src.cli.inputParserForBayesModel
.. autofunction:: src.cli.inputParserForCopy
.. autofunction:: src.cli.inputParserForCreateModel
.. autofunction:: src.cli.inputParserForCreateRoi
.. autofunction:: src.cli.inputParserForPreprocess
.. autofunction:: src.cli.inputParserForSmooth
.. autofunction:: src.cli.inputParserForStats

constants
=========
.. autofunction:: src.constants.bidsAppsActions
.. autofunction:: src.constants.lowLevelActions

defaults
========
.. autofunction:: src.defaults.ALI_my_defaults
.. autofunction:: src.defaults.MACS_my_defaults
.. autofunction:: src.defaults.checkOptions
.. autofunction:: src.defaults.defaultContrastsStructure
.. autofunction:: src.defaults.defaultResultsStructure
.. autofunction:: src.defaults.getOptionsFromModel
.. autofunction:: src.defaults.mniToIxi
.. autofunction:: src.defaults.setDirectories
.. autofunction:: src.defaults.setRenamingConfig
.. autofunction:: src.defaults.set_spm_2_bids_defaults
.. autofunction:: src.defaults.spm_my_defaults
.. autofunction:: src.defaults.validateResultsStructure

infra
=====
.. autofunction:: src.infra.checkDependencies
.. autofunction:: src.infra.checkToolbox
.. autofunction:: src.infra.elapsedTime
.. autofunction:: src.infra.getEnvInfo
.. autofunction:: src.infra.getRepoInfo
.. autofunction:: src.infra.getVersion
.. autofunction:: src.infra.resizeAliMask
.. autofunction:: src.infra.returnBsmDocURL
.. autofunction:: src.infra.returnHomeDir
.. autofunction:: src.infra.returnRepoURL
.. autofunction:: src.infra.returnRootDir
.. autofunction:: src.infra.returnRtdURL
.. autofunction:: src.infra.setGraphicWindow
.. autofunction:: src.infra.silenceOctaveWarning

messages
========
.. autofunction:: src.messages.bidspmHelp
.. autofunction:: src.messages.bugReport
.. autofunction:: src.messages.deprecated
.. autofunction:: src.messages.errorHandling
.. autofunction:: src.messages.logger
.. autofunction:: src.messages.noRoiFound
.. autofunction:: src.messages.notImplemented
.. autofunction:: src.messages.printAvailableContrasts
.. autofunction:: src.messages.printBatchName
.. autofunction:: src.messages.printCredits
.. autofunction:: src.messages.printProcessingSubject
.. autofunction:: src.messages.printToScreen
.. autofunction:: src.messages.printWorkflowName
.. autofunction:: src.messages.timeStamp

preproc
=======

fieldmaps
---------
.. autofunction:: src.preproc.fieldmaps.getBlipDirection
.. autofunction:: src.preproc.fieldmaps.getMetadataFromIntendedForFunc
.. autofunction:: src.preproc.fieldmaps.getTotalReadoutTime
.. autofunction:: src.preproc.fieldmaps.getVdmFile

utils
-----
.. autofunction:: src.preproc.utils.collectSrcMetadata
.. autofunction:: src.preproc.utils.createPialSurface
.. autofunction:: src.preproc.utils.getAcquisitionTime
.. autofunction:: src.preproc.utils.removeDummies
.. autofunction:: src.preproc.utils.segmentationAlreadyDone
.. autofunction:: src.preproc.utils.skullstrippingAlreadyDone
.. autofunction:: src.preproc.utils.transferMetadataFromJson

reports
=======
.. autofunction:: src.reports.boilerplate
.. autofunction:: src.reports.copyFigures
.. autofunction:: src.reports.copyGraphWindownOutput

partials
--------

stats
=====

results
-------
.. autofunction:: src.stats.results.convertPvalueToString
.. autofunction:: src.stats.results.renameNidm
.. autofunction:: src.stats.results.renameOutputResults
.. autofunction:: src.stats.results.renamePngCsvResults
.. autofunction:: src.stats.results.renameSpmT
.. autofunction:: src.stats.results.returnName
.. autofunction:: src.stats.results.returnResultNameSpec
.. autofunction:: src.stats.results.setMontage
.. autofunction:: src.stats.results.setNidm

subject_level
-------------
.. autofunction:: src.stats.subject_level.allRunsHaveSameNbRegressors
.. autofunction:: src.stats.subject_level.appendContrast
.. autofunction:: src.stats.subject_level.checkRegressorName
.. autofunction:: src.stats.subject_level.concatenateConfounds
.. autofunction:: src.stats.subject_level.concatenateImages
.. autofunction:: src.stats.subject_level.concatenateOnsets
.. autofunction:: src.stats.subject_level.concatenateRuns
.. autofunction:: src.stats.subject_level.constructContrastNameFromBidsEntity
.. autofunction:: src.stats.subject_level.convertOnsetTsvToMat
.. autofunction:: src.stats.subject_level.createAndReturnCounfoundMatFile
.. autofunction:: src.stats.subject_level.createAndReturnOnsetFile
.. autofunction:: src.stats.subject_level.createConfounds
.. autofunction:: src.stats.subject_level.deleteResidualImages
.. autofunction:: src.stats.subject_level.getBoldFilenameForFFX
.. autofunction:: src.stats.subject_level.getConfoundsRegressorFilename
.. autofunction:: src.stats.subject_level.getEventSpecificationRoiGlm
.. autofunction:: src.stats.subject_level.getEventsData
.. autofunction:: src.stats.subject_level.getFFXdir
.. autofunction:: src.stats.subject_level.getSessionForRegressorNb
.. autofunction:: src.stats.subject_level.newContrast
.. autofunction:: src.stats.subject_level.orderAndPadCounfoundMatFile
.. autofunction:: src.stats.subject_level.reorderCounfounds
.. autofunction:: src.stats.subject_level.sanitizeConfounds
.. autofunction:: src.stats.subject_level.saveRoiGlmSummaryTable
.. autofunction:: src.stats.subject_level.selectConfoundsByVarianceExplained
.. autofunction:: src.stats.subject_level.specifyContrasts
.. autofunction:: src.stats.subject_level.specifyDummyContrasts
.. autofunction:: src.stats.subject_level.specifySessionLvlContrasts
.. autofunction:: src.stats.subject_level.specifySubLvlContrasts

group_level
-----------
.. autofunction:: src.stats.group_level.computeCumulativeFwhm
.. autofunction:: src.stats.group_level.findSubjectConImage
.. autofunction:: src.stats.group_level.getRFXdir

utils
-----
.. autofunction:: src.stats.utils.checkSpmMat
.. autofunction:: src.stats.utils.createGlmDirName
.. autofunction:: src.stats.utils.designMatrixFigureName
.. autofunction:: src.stats.utils.endsWithRunNumber
.. autofunction:: src.stats.utils.fillInResultStructure
.. autofunction:: src.stats.utils.getContrastNb
.. autofunction:: src.stats.utils.getRegressorIdx
.. autofunction:: src.stats.utils.labelActivations
.. autofunction:: src.stats.utils.labelSpmSessWithBidsSesAndRun
.. autofunction:: src.stats.utils.removeIntercept
.. autofunction:: src.stats.utils.returnContrastImageFile
.. autofunction:: src.stats.utils.returnNumberScrubbedTimePoints
.. autofunction:: src.stats.utils.validateContrasts

utils
=====
.. autofunction:: src.utils.checkMaskOrUnderlay
.. autofunction:: src.utils.cleanUpWorkflow
.. autofunction:: src.utils.computeMeanValueInMask
.. autofunction:: src.utils.computeTsnr
.. autofunction:: src.utils.createDataDictionary
.. autofunction:: src.utils.deregexify
.. autofunction:: src.utils.displayArguments
.. autofunction:: src.utils.getDist2surf
.. autofunction:: src.utils.getFuncVoxelDims
.. autofunction:: src.utils.regexify
.. autofunction:: src.utils.renamePng
.. autofunction:: src.utils.returnBatchFileName
.. autofunction:: src.utils.returnDependency
.. autofunction:: src.utils.returnVolumeList
.. autofunction:: src.utils.setFields
.. autofunction:: src.utils.setUpWorkflow
.. autofunction:: src.utils.tempName
.. autofunction:: src.utils.unfoldStruct
.. autofunction:: src.utils.validationInputFile
.. autofunction:: src.utils.volumeSplicing

validators
==========
.. autofunction:: src.validators.isMni
.. autofunction:: src.validators.isSkullstripped
.. autofunction:: src.validators.isTtest
.. autofunction:: src.validators.isZipped
