.. _dev_doc:

API
***

At the highest levels bidspm is organized in workflows:

- they all start with the prefix ``bids`` (for example ``bidsRealignReslice``)
- they are in the folder ``src/workflows``
- they run on all the subjects specified in the ``options`` structure.

Most workflows run by creating matlab batches that are saved as ``.mat`` files in a ``jobs``
then passed to the SPM jobman to run.
To do this the workflows call "batch creating functions":

- all start with the prefix ``setBatch`` (for example ``setBatchCoregistration``).
- are in the folder ``src/batches``.

Many workflows include some post-processing steps (like file renaming) after the execution of the batch,
so in many cases the output of running just the batch and running the whole workflow
will be different.

:ref:`preprocessing`, :ref:`statistics` and :ref:`fieldmaps_page` handling have their own document pages.

Other workflows, batches and related helper functions are listed below.


.. AUTOMATICALLY GENERATED

workflows
=========
.. autofunction:: src/workflows/bidsChangeSuffix.m
.. autofunction:: src/workflows/bidsCheckVoxelSize.m
.. autofunction:: src/workflows/bidsCopyInputFolder.m
.. autofunction:: src/workflows/bidsInverseNormalize.m
.. autofunction:: src/workflows/bidsRename.m
.. autofunction:: src/workflows/bidsReport.m

roi
---
.. autofunction:: src/workflows/roi/bidsCreateROI.m
.. autofunction:: src/workflows/roi/bidsRoiBasedGLM.m

QA
--
.. autofunction:: src/workflows/QA/bidsQA.m
.. autofunction:: src/workflows/QA/bidsQAbidspm.m
.. autofunction:: src/workflows/QA/bidsQAmriqc.m
.. autofunction:: src/workflows/QA/bidsQApreproc.m

lesion
------
.. autofunction:: src/workflows/lesion/bidsLesionAbnormalitiesDetection.m
.. autofunction:: src/workflows/lesion/bidsLesionOverlapMap.m
.. autofunction:: src/workflows/lesion/bidsLesionSegmentation.m

stats
-----
.. autofunction:: src/workflows/stats/bidsConcatBetaTmaps.m
.. autofunction:: src/workflows/stats/bidsFFX.m
.. autofunction:: src/workflows/stats/bidsModelSelection.m
.. autofunction:: src/workflows/stats/bidsRFX.m
.. autofunction:: src/workflows/stats/bidsResults.m
.. autofunction:: src/workflows/stats/bidsSmoothContrasts.m

preproc
-------
.. autofunction:: src/workflows/preproc/bidsCreateVDM.m
.. autofunction:: src/workflows/preproc/bidsGenerateT1map.m
.. autofunction:: src/workflows/preproc/bidsRealignReslice.m
.. autofunction:: src/workflows/preproc/bidsRealignUnwarp.m
.. autofunction:: src/workflows/preproc/bidsRemoveDummies.m
.. autofunction:: src/workflows/preproc/bidsResliceTpmToFunc.m
.. autofunction:: src/workflows/preproc/bidsSTC.m
.. autofunction:: src/workflows/preproc/bidsSegmentSkullStrip.m
.. autofunction:: src/workflows/preproc/bidsSmoothing.m
.. autofunction:: src/workflows/preproc/bidsSpatialPrepro.m
.. autofunction:: src/workflows/preproc/bidsWholeBrainFuncMask.m

batches
=======
.. autofunction:: src/batches/saveMatlabBatch.m
.. autofunction:: src/batches/setBachRename.m
.. autofunction:: src/batches/setBatch3Dto4D.m
.. autofunction:: src/batches/setBatchImageCalculation.m
.. autofunction:: src/batches/setBatchMeanAnatAndMask.m
.. autofunction:: src/batches/setBatchPrintFigure.m
.. autofunction:: src/batches/setBatchReorient.m
.. autofunction:: src/batches/setBatchSelectAnat.m

lesion
------
.. autofunction:: src/batches/lesion/setBatchLesionAbnormalitiesDetection.m
.. autofunction:: src/batches/lesion/setBatchLesionOverlapMap.m
.. autofunction:: src/batches/lesion/setBatchLesionSegmentation.m

stats
-----
.. autofunction:: src/batches/stats/setBatchContrasts.m
.. autofunction:: src/batches/stats/setBatchEstimateModel.m
.. autofunction:: src/batches/stats/setBatchFactorialDesign.m
.. autofunction:: src/batches/stats/setBatchFactorialDesignGlobalCalcAndNorm.m
.. autofunction:: src/batches/stats/setBatchFactorialDesignImplicitMasking.m
.. autofunction:: src/batches/stats/setBatchGoodnessOfFit.m
.. autofunction:: src/batches/stats/setBatchGroupLevelContrasts.m
.. autofunction:: src/batches/stats/setBatchGroupLevelResults.m
.. autofunction:: src/batches/stats/setBatchInformationCriteria.m
.. autofunction:: src/batches/stats/setBatchResults.m
.. autofunction:: src/batches/stats/setBatchSubjectLevelContrasts.m
.. autofunction:: src/batches/stats/setBatchSubjectLevelGLMSpec.m
.. autofunction:: src/batches/stats/setBatchSubjectLevelResults.m

preproc
-------
.. autofunction:: src/batches/preproc/setBatchComputeVDM.m
.. autofunction:: src/batches/preproc/setBatchCoregistration.m
.. autofunction:: src/batches/preproc/setBatchCoregistrationFmap.m
.. autofunction:: src/batches/preproc/setBatchCoregistrationFuncToAnat.m
.. autofunction:: src/batches/preproc/setBatchCreateVDMs.m
.. autofunction:: src/batches/preproc/setBatchGenerateT1map.m
.. autofunction:: src/batches/preproc/setBatchInverseNormalize.m
.. autofunction:: src/batches/preproc/setBatchNormalizationSpatialPrepro.m
.. autofunction:: src/batches/preproc/setBatchNormalize.m
.. autofunction:: src/batches/preproc/setBatchRealign.m
.. autofunction:: src/batches/preproc/setBatchRenameSegmentParameter.m
.. autofunction:: src/batches/preproc/setBatchReslice.m
.. autofunction:: src/batches/preproc/setBatchSTC.m
.. autofunction:: src/batches/preproc/setBatchSaveCoregistrationMatrix.m
.. autofunction:: src/batches/preproc/setBatchSegmentation.m
.. autofunction:: src/batches/preproc/setBatchSkullStripping.m
.. autofunction:: src/batches/preproc/setBatchSmoothConImages.m
.. autofunction:: src/batches/preproc/setBatchSmoothing.m
.. autofunction:: src/batches/preproc/setBatchSmoothingAnat.m
.. autofunction:: src/batches/preproc/setBatchSmoothingFunc.m

IO
==
.. autofunction:: src/IO/addGitIgnore.m
.. autofunction:: src/IO/addLicense.m
.. autofunction:: src/IO/addReadme.m
.. autofunction:: src/IO/cleanCrash.m
.. autofunction:: src/IO/convertRealignParamToTsv.m
.. autofunction:: src/IO/createDerivativeDir.m
.. autofunction:: src/IO/getData.m
.. autofunction:: src/IO/loadAndCheckOptions.m
.. autofunction:: src/IO/onsetsMatToTsv.m
.. autofunction:: src/IO/overwriteDir.m
.. autofunction:: src/IO/regressorsMatToTsv.m
.. autofunction:: src/IO/renameSegmentParameter.m
.. autofunction:: src/IO/renameUnwarpParameter.m
.. autofunction:: src/IO/saveAndRunWorkflow.m
.. autofunction:: src/IO/saveOptions.m
.. autofunction:: src/IO/saveSpmScript.m
.. autofunction:: src/IO/unzipAndReturnsFullpathName.m

QA
==
.. autofunction:: src/QA/anatQA.m
.. autofunction:: src/QA/censoring.m
.. autofunction:: src/QA/compileScrubbingStats.m
.. autofunction:: src/QA/computeDesignEfficiency.m
.. autofunction:: src/QA/computeFDandRMS.m
.. autofunction:: src/QA/computeRobustOutliers.m
.. autofunction:: src/QA/createDesignMatrix.m
.. autofunction:: src/QA/plotConfounds.m
.. autofunction:: src/QA/plotEvents.m
.. autofunction:: src/QA/plotRoiTimeCourse.m
.. autofunction:: src/QA/realignQA.m

bids
====
.. autofunction:: src/bids/addStcToQuery.m
.. autofunction:: src/bids/buildIndividualSpaceRoiFilename.m
.. autofunction:: src/bids/checkFmriprep.m
.. autofunction:: src/bids/fileFilterForBold.m
.. autofunction:: src/bids/generatedBy.m
.. autofunction:: src/bids/getAnatFilename.m
.. autofunction:: src/bids/getAndCheckRepetitionTime.m
.. autofunction:: src/bids/getAndCheckSliceOrder.m
.. autofunction:: src/bids/getAvailableGroups.m
.. autofunction:: src/bids/getBoldFilename.m
.. autofunction:: src/bids/getInfo.m
.. autofunction:: src/bids/getMeanFuncFilename.m
.. autofunction:: src/bids/getROIs.m
.. autofunction:: src/bids/getSubjectList.m
.. autofunction:: src/bids/getTpmFilename.m
.. autofunction:: src/bids/initBids.m
.. autofunction:: src/bids/removeEmptyQueryFields.m
.. autofunction:: src/bids/returnNameSkullstripOutput.m
.. autofunction:: src/bids/roiGlmOutputName.m
.. autofunction:: src/bids/validate.m

bids_model
==========
.. autofunction:: src/bids_model/checkContrast.m
.. autofunction:: src/bids_model/createDefaultStatsModel.m
.. autofunction:: src/bids_model/createModelFamilies.m
.. autofunction:: src/bids_model/getContrastsFromParentNode.m
.. autofunction:: src/bids_model/getContrastsList.m
.. autofunction:: src/bids_model/getContrastsListForFactorialDesign.m
.. autofunction:: src/bids_model/getDummyContrastFromParentNode.m
.. autofunction:: src/bids_model/getDummyContrastsList.m
.. autofunction:: src/bids_model/getInclusiveMask.m

bidspm
======

data
----

__pycache__
-----------

cli
===
.. autofunction:: src/cli/baseInputParser.m
.. autofunction:: src/cli/cliBayesModel.m
.. autofunction:: src/cli/cliCopy.m
.. autofunction:: src/cli/cliCreateRoi.m
.. autofunction:: src/cli/cliDefaultModel.m
.. autofunction:: src/cli/cliPreprocess.m
.. autofunction:: src/cli/cliSmooth.m
.. autofunction:: src/cli/cliStats.m
.. autofunction:: src/cli/getBidsFilterFile.m
.. autofunction:: src/cli/getOptionsFromCliArgument.m
.. autofunction:: src/cli/inputParserForBayesModel.m
.. autofunction:: src/cli/inputParserForCopy.m
.. autofunction:: src/cli/inputParserForCreateModel.m
.. autofunction:: src/cli/inputParserForCreateRoi.m
.. autofunction:: src/cli/inputParserForPreprocess.m
.. autofunction:: src/cli/inputParserForSmooth.m
.. autofunction:: src/cli/inputParserForStats.m

constants
=========
.. autofunction:: src/constants/bidsAppsActions.m
.. autofunction:: src/constants/lowLevelActions.m

defaults
========
.. autofunction:: src/defaults/ALI_my_defaults.m
.. autofunction:: src/defaults/MACS_my_defaults.m
.. autofunction:: src/defaults/checkOptions.m
.. autofunction:: src/defaults/defaultContrastsStructure.m
.. autofunction:: src/defaults/defaultResultsStructure.m
.. autofunction:: src/defaults/getOptionsFromModel.m
.. autofunction:: src/defaults/mniToIxi.m
.. autofunction:: src/defaults/setDirectories.m
.. autofunction:: src/defaults/setRenamingConfig.m
.. autofunction:: src/defaults/set_spm_2_bids_defaults.m
.. autofunction:: src/defaults/spm_my_defaults.m
.. autofunction:: src/defaults/validateResultsStructure.m

infra
=====
.. autofunction:: src/infra/checkDependencies.m
.. autofunction:: src/infra/checkToolbox.m
.. autofunction:: src/infra/elapsedTime.m
.. autofunction:: src/infra/getEnvInfo.m
.. autofunction:: src/infra/getRepoInfo.m
.. autofunction:: src/infra/getVersion.m
.. autofunction:: src/infra/resizeAliMask.m
.. autofunction:: src/infra/returnBsmDocURL.m
.. autofunction:: src/infra/returnHomeDir.m
.. autofunction:: src/infra/returnRepoURL.m
.. autofunction:: src/infra/returnRootDir.m
.. autofunction:: src/infra/returnRtdURL.m
.. autofunction:: src/infra/setGraphicWindow.m
.. autofunction:: src/infra/silenceOctaveWarning.m

messages
========
.. autofunction:: src/messages/bidspmHelp.m
.. autofunction:: src/messages/bugReport.m
.. autofunction:: src/messages/deprecated.m
.. autofunction:: src/messages/errorHandling.m
.. autofunction:: src/messages/logger.m
.. autofunction:: src/messages/noRoiFound.m
.. autofunction:: src/messages/notImplemented.m
.. autofunction:: src/messages/printAvailableContrasts.m
.. autofunction:: src/messages/printBatchName.m
.. autofunction:: src/messages/printCredits.m
.. autofunction:: src/messages/printProcessingSubject.m
.. autofunction:: src/messages/printToScreen.m
.. autofunction:: src/messages/printWorkflowName.m
.. autofunction:: src/messages/timeStamp.m

preproc
=======

fieldmaps
---------
.. autofunction:: src/preproc/fieldmaps/getBlipDirection.m
.. autofunction:: src/preproc/fieldmaps/getMetadataFromIntendedForFunc.m
.. autofunction:: src/preproc/fieldmaps/getTotalReadoutTime.m
.. autofunction:: src/preproc/fieldmaps/getVdmFile.m

utils
-----
.. autofunction:: src/preproc/utils/collectSrcMetadata.m
.. autofunction:: src/preproc/utils/createPialSurface.m
.. autofunction:: src/preproc/utils/getAcquisitionTime.m
.. autofunction:: src/preproc/utils/removeDummies.m
.. autofunction:: src/preproc/utils/segmentationAlreadyDone.m
.. autofunction:: src/preproc/utils/skullstrippingAlreadyDone.m
.. autofunction:: src/preproc/utils/transferMetadataFromJson.m

reports
=======
.. autofunction:: src/reports/boilerplate.m
.. autofunction:: src/reports/copyFigures.m
.. autofunction:: src/reports/copyGraphWindownOutput.m

partials
--------

stats
=====

results
-------
.. autofunction:: src/stats/results/convertPvalueToString.m
.. autofunction:: src/stats/results/renameNidm.m
.. autofunction:: src/stats/results/renameOutputResults.m
.. autofunction:: src/stats/results/renamePngCsvResults.m
.. autofunction:: src/stats/results/renameSpmT.m
.. autofunction:: src/stats/results/returnName.m
.. autofunction:: src/stats/results/returnResultNameSpec.m
.. autofunction:: src/stats/results/setMontage.m
.. autofunction:: src/stats/results/setNidm.m

subject_level
-------------
.. autofunction:: src/stats/subject_level/allRunsHaveSameNbRegressors.m
.. autofunction:: src/stats/subject_level/appendContrast.m
.. autofunction:: src/stats/subject_level/checkRegressorName.m
.. autofunction:: src/stats/subject_level/concatenateConfounds.m
.. autofunction:: src/stats/subject_level/concatenateImages.m
.. autofunction:: src/stats/subject_level/concatenateOnsets.m
.. autofunction:: src/stats/subject_level/concatenateRuns.m
.. autofunction:: src/stats/subject_level/constructContrastNameFromBidsEntity.m
.. autofunction:: src/stats/subject_level/convertOnsetTsvToMat.m
.. autofunction:: src/stats/subject_level/createAndReturnCounfoundMatFile.m
.. autofunction:: src/stats/subject_level/createAndReturnOnsetFile.m
.. autofunction:: src/stats/subject_level/createConfounds.m
.. autofunction:: src/stats/subject_level/deleteResidualImages.m
.. autofunction:: src/stats/subject_level/getBoldFilenameForFFX.m
.. autofunction:: src/stats/subject_level/getConfoundsRegressorFilename.m
.. autofunction:: src/stats/subject_level/getEventSpecificationRoiGlm.m
.. autofunction:: src/stats/subject_level/getEventsData.m
.. autofunction:: src/stats/subject_level/getFFXdir.m
.. autofunction:: src/stats/subject_level/getSessionForRegressorNb.m
.. autofunction:: src/stats/subject_level/newContrast.m
.. autofunction:: src/stats/subject_level/orderAndPadCounfoundMatFile.m
.. autofunction:: src/stats/subject_level/reorderCounfounds.m
.. autofunction:: src/stats/subject_level/sanitizeConfounds.m
.. autofunction:: src/stats/subject_level/saveRoiGlmSummaryTable.m
.. autofunction:: src/stats/subject_level/selectConfoundsByVarianceExplained.m
.. autofunction:: src/stats/subject_level/specifyContrasts.m
.. autofunction:: src/stats/subject_level/specifyDummyContrasts.m
.. autofunction:: src/stats/subject_level/specifySessionLvlContrasts.m
.. autofunction:: src/stats/subject_level/specifySubLvlContrasts.m

group_level
-----------
.. autofunction:: src/stats/group_level/computeCumulativeFwhm.m
.. autofunction:: src/stats/group_level/findSubjectConImage.m
.. autofunction:: src/stats/group_level/getRFXdir.m

utils
-----
.. autofunction:: src/stats/utils/checkSpmMat.m
.. autofunction:: src/stats/utils/createGlmDirName.m
.. autofunction:: src/stats/utils/designMatrixFigureName.m
.. autofunction:: src/stats/utils/endsWithRunNumber.m
.. autofunction:: src/stats/utils/fillInResultStructure.m
.. autofunction:: src/stats/utils/getContrastNb.m
.. autofunction:: src/stats/utils/getRegressorIdx.m
.. autofunction:: src/stats/utils/labelActivations.m
.. autofunction:: src/stats/utils/labelSpmSessWithBidsSesAndRun.m
.. autofunction:: src/stats/utils/removeIntercept.m
.. autofunction:: src/stats/utils/returnContrastImageFile.m
.. autofunction:: src/stats/utils/returnNumberScrubbedTimePoints.m
.. autofunction:: src/stats/utils/validateContrasts.m

utils
=====
.. autofunction:: src/utils/checkMaskOrUnderlay.m
.. autofunction:: src/utils/cleanUpWorkflow.m
.. autofunction:: src/utils/computeMeanValueInMask.m
.. autofunction:: src/utils/computeTsnr.m
.. autofunction:: src/utils/createDataDictionary.m
.. autofunction:: src/utils/deregexify.m
.. autofunction:: src/utils/displayArguments.m
.. autofunction:: src/utils/getDist2surf.m
.. autofunction:: src/utils/getFuncVoxelDims.m
.. autofunction:: src/utils/regexify.m
.. autofunction:: src/utils/renamePng.m
.. autofunction:: src/utils/returnBatchFileName.m
.. autofunction:: src/utils/returnDependency.m
.. autofunction:: src/utils/returnVolumeList.m
.. autofunction:: src/utils/setFields.m
.. autofunction:: src/utils/setUpWorkflow.m
.. autofunction:: src/utils/tempName.m
.. autofunction:: src/utils/unfoldStruct.m
.. autofunction:: src/utils/validationInputFile.m
.. autofunction:: src/utils/volumeSplicing.m

validators
==========
.. autofunction:: src/validators/isMni.m
.. autofunction:: src/validators/isSkullstripped.m
.. autofunction:: src/validators/isTtest.m
.. autofunction:: src/validators/isZipped.m
