# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!--
### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security
-->

## [Unreleased]


### Added

* [ENH] add QA workflow `bidsQA` to find outliers in MRIQC output or to view number of outlier timepoints (for a given metric and threshold) in each functional run #1297 by @Remi-Gau
* [ENH] add support for one-way ANOVA across groups at the group level #1296 by @Remi-Gau
* [ENH] allow for 2 sample T-Test, within group T-Test and one-way ANOVA to ne more flexible with respect to what praticipants.tsv column to use to allocate subjects in each group #1296 by @Remi-Gau
* [ENH] make `addConfoundsToDesignMatrix` a method of `BidsModel` #1294 by @Remi-Gau
* [ENH] add Apptainer definition #1254 by @Remi-Gau and @monique2208
* [ENH] allow to copy anat only on raw datasets #1181 by @Remi-Gau
* [ENH] add option to concatenate runs at subject level to facilite running PPI analysis #1133 by @Remi-Gau
* [ENH] allow to run substeps of substeps of the bayesian model selection #1145 by @Remi-Gau
* [ENH] add quality control for GLM using the MACS toolbox to give a goodness of fit and several other information criteria (AIC, BIC) (MATLAB only) #1135  by @Remi-Gau
* [ENH] add several confound strategies to add to bids stats model and a function to create family of models #1126 by @Remi-Gau
* [ENH] add CLI to run bayesian model selection #1121 by @Remi-Gau
* [ENH] support label of activations with all atlases [1100](https://github.com/cpp-lln-lab/bidspm/pull/1100) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] add support for session level models #1116 be @Remi-Gau

  - allow to pass dummy contrasts to session level
  - allow inter session contrasts to be computed at the subject level
  - improve naming of contrast to mention bids ses and run

* [ENH] add Bayesian model selection to the python CLI #1292 @Remi-Gau

### Changed

* [ENH] align specification of F contrasts on the BIDS stats model: they should now be specified as a 2D matrix and not a 1D vector. #1276 @Remi-Gau
* [DOC] change theme and structure of the documentation #1256 @Remi-Gau
* [REF] Refactor and update CLI in #1096 @Remi-Gau
* [ENH] {func}`getData` only loads anat data when requested #1257 @Remi-Gau
* [ENH] the python CLI now uses sub-commands instead of the named parameter `--action` #1292 @Remi-Gau
* [ENH] change base image in container to use Octave 9.2.0 #1308 @Remi-Gau

### Deprecated

### Removed

* [REF] Remove old CLI in #1096 @Remi-Gau

### Fixed

* [FIX] ensure that {func}`setBatchCoregistrationFuncToAnat` takes into account bids_filter #1295 by @d-ni374
* [FIX] update {func}`createDefaultStatsModel` to use proper `GroupBy` at the dataset level #1248 by @d-ni374
* [FIX] make {func}`getAcquisitionTime` less brittle #1248 by @d-ni374
* [FIX] fix regular expression in {func}`bidsResults` to identify contrasts #1248 by @d-ni374 and #1275 by @Remi-Gau
* [FIX] pass analysis level to stats actions when using python CLI #1258 @Remi-Gau
* [FIX] remove goodness of fit from dataset level analysis as it is not supported by the MACS toolbox #1265 by @Remi-Gau
* [FIX] add java and zip to container recipes to allow using nidm results with octave #1265 by @Remi-Gau
* [FIX] copy the MACS toolbox to the SPM toolbox folder during the initialisation #1203 by @Remi-Gau
* [FIX] save `onsets.mat` directly in subject stats folder #1187 by @Remi-Gau
* [FIX] do not compute subject level contrast when running dataset level #1102 by @Remi-Gau
* [FIX] copy `RepetitionTime` in sidecar JSON after running smoothing in #1099 by @Remi-Gau
* [FIX] rename results files (csv, tsv, png, nii) of each contrasts #1104 by @Remi-Gau
* [FIX] reslice ROIS before running ROI based analysis to make sure they are at the resolution of the BOLD images in #1110 by @Remi-Gau
* [FIX] ensure that there is a clean version number in containers #1306 @Remi-Gau

### Security


## [3.1.0] - 2023-07-01

**Full Changelog**: https://github.com/cpp-lln-lab/bidspm/compare/v3.0.0...v3.1.0

### Added

* [DOC] add changelog in [1056](https://github.com/cpp-lln-lab/bidspm/pull/1056) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] minor doc fixes in [1020](https://github.com/cpp-lln-lab/bidspm/pull/1020) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] Improve doc example out stats in [1014](https://github.com/cpp-lln-lab/bidspm/pull/1014) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] update doc regarding FAST model as default in [985](https://github.com/cpp-lln-lab/bidspm/pull/985) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] update contributors and default options in doc in [981](https://github.com/cpp-lln-lab/bidspm/pull/981) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] add doc to link to transformations in [942](https://github.com/cpp-lln-lab/bidspm/pull/942) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] add demo code from workshop in [935](https://github.com/cpp-lln-lab/bidspm/pull/935) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] abstract OHBM 2023 in [934](https://github.com/cpp-lln-lab/bidspm/pull/934) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] add argument groups to python cli in [907](https://github.com/cpp-lln-lab/bidspm/pull/907) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] update FAQ in [897](https://github.com/cpp-lln-lab/bidspm/pull/897) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] add proper error when a column cannot be found in participants.tsv in [1050](https://github.com/cpp-lln-lab/bidspm/pull/1050) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] update CPP ROI and add methods section for ROI creation in [1026](https://github.com/cpp-lln-lab/bidspm/pull/1026) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] update rename to store original spm name of a file in metadata in [987](https://github.com/cpp-lln-lab/bidspm/pull/987) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] add hemisphere parameter to CLI in [950](https://github.com/cpp-lln-lab/bidspm/pull/950) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] make it possible to update bidspm from any folder in [948](https://github.com/cpp-lln-lab/bidspm/pull/948) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] use filtering of layout in [944](https://github.com/cpp-lln-lab/bidspm/pull/944) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] make reports more silent in [939](https://github.com/cpp-lln-lab/bidspm/pull/939) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] add CC0 license by default to all outputs in [898](https://github.com/cpp-lln-lab/bidspm/pull/898) by [Remi-Gau](https://github.com/Remi-Gau)

### Changed

* [ENH] overwrite files when renaming by default in [1051](https://github.com/cpp-lln-lab/bidspm/pull/1051) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] turn error into warning when no data to copy found in [992](https://github.com/cpp-lln-lab/bidspm/pull/992) by [Remi-Gau](https://github.com/Remi-Gau)

### Removed

* [ENH] drop rsHRF support in [906](https://github.com/cpp-lln-lab/bidspm/pull/906) by [Remi-Gau](https://github.com/Remi-Gau)

### Fixed

* [FIX] fix vismotion demo in [1070](https://github.com/cpp-lln-lab/bidspm/pull/1070) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] Exclude from GLM specification events with onsets longer than the run duration in [1060](https://github.com/cpp-lln-lab/bidspm/pull/1060) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] remove dummies from preproc dataset and not raw dataset when using CLI in [1057](https://github.com/cpp-lln-lab/bidspm/pull/1057) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] skip smoothing when running bidspm prepoc in dryRun in [1054](https://github.com/cpp-lln-lab/bidspm/pull/1054) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] handle phase entity in filename in [1034](https://github.com/cpp-lln-lab/bidspm/pull/1034) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] fix group level results after contrasts smoothing  in [1021](https://github.com/cpp-lln-lab/bidspm/pull/1021) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] copy to derivatives handles bids filter file and minimize re copying files that already exist in [1015](https://github.com/cpp-lln-lab/bidspm/pull/1015) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] allow cli to run constrat smoothing in [1012](https://github.com/cpp-lln-lab/bidspm/pull/1012) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] Force copy of data from fmriprep folder even if bidspm-preproc folder exists in [1009](https://github.com/cpp-lln-lab/bidspm/pull/1009) by [marcobarilari](https://github.com/marcobarilari)
* [FIX] report proper fold number in labelfold.tsv in [989](https://github.com/cpp-lln-lab/bidspm/pull/989) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] inconsistent slice timing throw errors and not warnings in [982](https://github.com/cpp-lln-lab/bidspm/pull/982) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] validate condition names early to avoid downstream error in [983](https://github.com/cpp-lln-lab/bidspm/pull/983) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] validate content results structure in [980](https://github.com/cpp-lln-lab/bidspm/pull/980) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] missing variable for a Filter transform should not lead to a crash in [970](https://github.com/cpp-lln-lab/bidspm/pull/970) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] display error when impossible slice timing values are given in [969](https://github.com/cpp-lln-lab/bidspm/pull/969) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] fix QA failures in [941](https://github.com/cpp-lln-lab/bidspm/pull/941) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] bug fix 892 in [936](https://github.com/cpp-lln-lab/bidspm/pull/936) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] fix python cli in [888](https://github.com/cpp-lln-lab/bidspm/pull/888) by [Remi-Gau](https://github.com/Remi-Gau)

## [3.0.0] - 2022-12-14

**Full Changelog**: https://github.com/cpp-lln-lab/bidspm/compare/v2.3.0...v3.0.0

### Changed

* [DEP] deprecate slice order in options in [882](https://github.com/cpp-lln-lab/bidspm/pull/882) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] change the way parametric models are run in [873](https://github.com/cpp-lln-lab/bidspm/pull/873) by [Remi-Gau](https://github.com/Remi-Gau)*

### Added

* [ENH] include roi based calls in CLI  in [880](https://github.com/cpp-lln-lab/bidspm/pull/880) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] add copy dataset to CLI in [842](https://github.com/cpp-lln-lab/bidspm/pull/842) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] add smoothing to CLI in [841](https://github.com/cpp-lln-lab/bidspm/pull/841) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] create docker image of bids app - Octave in [837](https://github.com/cpp-lln-lab/bidspm/pull/837) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] use python based CLI to run bidspm with octave in [832](https://github.com/cpp-lln-lab/bidspm/pull/832) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] update CPP_ROI in [885](https://github.com/cpp-lln-lab/bidspm/pull/885) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] add extra files to derivatives datasets in [883](https://github.com/cpp-lln-lab/bidspm/pull/883) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] incorporate opt.results in bids stats model in [879](https://github.com/cpp-lln-lab/bidspm/pull/879) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] add option to ignore creating dataset level node in default model in [871](https://github.com/cpp-lln-lab/bidspm/pull/871) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] implement logger in [867](https://github.com/cpp-lln-lab/bidspm/pull/867) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] add function to return contrast filename for a certain contrast name in [866](https://github.com/cpp-lln-lab/bidspm/pull/866) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] update FAQ to explain how to change subject level GLM folder name in [872](https://github.com/cpp-lln-lab/bidspm/pull/872) by [Remi-Gau](https://github.com/Remi-Gau)

### Fixed

* [FIX] better handle metadata when changing suffix in [884](https://github.com/cpp-lln-lab/bidspm/pull/884) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] exit with a warning and not an error when no contrast specified in [870](https://github.com/cpp-lln-lab/bidspm/pull/870) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] fix SPM loading in returnContrastImageFile in [869](https://github.com/cpp-lln-lab/bidspm/pull/869) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] fix make file in [868](https://github.com/cpp-lln-lab/bidspm/pull/868) by [Remi-Gau](https://github.com/Remi-Gau)

## [2.3.0] - 2022-11-22

**Full Changelog**: https://github.com/cpp-lln-lab/bidspm/compare/v2.2.0...v2.3.0

- `bidspm` main function:
  - saving options are saved to help with bug report
  - generate method section in reports folder when running preprocess or statistics

### Added

* [DOC] add auto label of activation info in [821](https://github.com/cpp-lln-lab/bidspm/pull/821) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] improve bids model warning in [820](https://github.com/cpp-lln-lab/bidspm/pull/820) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] add all functions to doc in [819](https://github.com/cpp-lln-lab/bidspm/pull/819) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] add design only to CLI [772](https://github.com/cpp-lln-lab/bidspm/pull/772)
* [ENH] smoothing workflow will also try to smooth the corresponding anat data too
* [ENH] save skipped ROIs and concat beta maps in [823](https://github.com/cpp-lln-lab/bidspm/pull/823) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] add boilerplate to CLI in [822](https://github.com/cpp-lln-lab/bidspm/pull/822) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] error logs are generated upon crash for better bug reports in [808](https://github.com/cpp-lln-lab/bidspm/pull/808) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] Use CLI to create default model in [804](https://github.com/cpp-lln-lab/bidspm/pull/804) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] include bids and bids stats model validation if the validators are installed in [787](https://github.com/cpp-lln-lab/bidspm/pull/787) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] add inverse normalize workflow in [784](https://github.com/cpp-lln-lab/bidspm/pull/784) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] lesion detection will be done by including the CSF TPM too in [778](https://github.com/cpp-lln-lab/bidspm/pull/778) by [Remi-Gau](https://github.com/Remi-Gau)

### Fixed

* [FIX] fix printing of windows path in [812](https://github.com/cpp-lln-lab/bidspm/pull/812) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] use glob patterns to define dummy contrasts in [826](https://github.com/cpp-lln-lab/bidspm/pull/826) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] rm desc when renamining some files in lesion segemtation in [817](https://github.com/cpp-lln-lab/bidspm/pull/817) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] avoid duplicate contrasts in [816](https://github.com/cpp-lln-lab/bidspm/pull/816) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] make collecting of OS version on windows more robust in [806](https://github.com/cpp-lln-lab/bidspm/pull/806) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] throw warning when no results are asked in [795](https://github.com/cpp-lln-lab/bidspm/pull/795) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] fix windows bugs in [792](https://github.com/cpp-lln-lab/bidspm/pull/792) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] fix spelling in [789](https://github.com/cpp-lln-lab/bidspm/pull/789) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] fix and tidy failing workflows in [774](https://github.com/cpp-lln-lab/bidspm/pull/774) by [Remi-Gau](https://github.com/Remi-Gau)

## [2.2.0] - 2022-10-29

**Full Changelog**: https://github.com/cpp-lln-lab/bidspm/compare/v2.1.0...v2.2.0

### Added

* [DOC] use new copyright format in [750](https://github.com/cpp-lln-lab/bidspm/pull/750) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] improve stats doc and warnings in [746](https://github.com/cpp-lln-lab/bidspm/pull/746) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] add design only to CLI in [772](https://github.com/cpp-lln-lab/bidspm/pull/772) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] add functions to help select fmriprep regressors in [748](https://github.com/cpp-lln-lab/bidspm/pull/748) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] start switching to bidspm in [747](https://github.com/cpp-lln-lab/bidspm/pull/747) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] use inputs from several datasets for lesion abnormality detection in [730](https://github.com/cpp-lln-lab/bidspm/pull/730) by [Remi-Gau](https://github.com/Remi-Gau)
* [ENH] Update bidspm path in [752](https://github.com/cpp-lln-lab/bidspm/pull/752) by [Remi-Gau](https://github.com/Remi-Gau)

### Changed

* [DEP] update bids matlab in [734](https://github.com/cpp-lln-lab/bidspm/pull/734) by [Remi-Gau](https://github.com/Remi-Gau)

### Fixed

* [FIX] fixes workflow timing in [773](https://github.com/cpp-lln-lab/bidspm/pull/773) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] related to [763](https://github.com/cpp-lln-lab/bidspm/pull/763) and testing through CI if the patch breaks things (reopened) in [765](https://github.com/cpp-lln-lab/bidspm/pull/765) by [marcobarilari](https://github.com/marcobarilari)

## [2.1.0] - 2022-07-21

**Full Changelog**: https://github.com/cpp-lln-lab/bidspm/compare/v2.0.0...v2.1.0

### Added

* [ENH] add possibility to use AAL for labelling of activations in [717](https://github.com/cpp-lln-lab/bidspm/pull/717) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] update FAQ to help structure data to run stats on fmriprep in [685](https://github.com/cpp-lln-lab/bidspm/pull/685) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] add demo for ds002799 in [678](https://github.com/cpp-lln-lab/bidspm/pull/678) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] add DIY section to documtation in [677](https://github.com/cpp-lln-lab/bidspm/pull/677) by [Remi-Gau](https://github.com/Remi-Gau)
* [DOC] improve description of stats output and of bids stats model in [670](https://github.com/cpp-lln-lab/bidspm/pull/670) by [Remi-Gau](https://github.com/Remi-Gau)

### Changed

* [MNT] update citation file in [721](https://github.com/cpp-lln-lab/bidspm/pull/721) by [Remi-Gau](https://github.com/Remi-Gau)
* [DEP] update bids matlab in [680](https://github.com/cpp-lln-lab/bidspm/pull/680) by [Remi-Gau](https://github.com/Remi-Gau)

### Fixed

* [FIX] fix lesion segmentation output (and refactor) in [727](https://github.com/cpp-lln-lab/bidspm/pull/727) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] add more explicit error message for input parsing of getData in [726](https://github.com/cpp-lln-lab/bidspm/pull/726) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] support globbing patterns to specify conditions in design matrix in [716](https://github.com/cpp-lln-lab/bidspm/pull/716) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] fix ALI toolbox issues in [723](https://github.com/cpp-lln-lab/bidspm/pull/723) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] improve warning selecting too many masks in [715](https://github.com/cpp-lln-lab/bidspm/pull/715) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] fix and refactor demos, and update help sections in [701](https://github.com/cpp-lln-lab/bidspm/pull/701) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] add guard clauses to run ROI based analysis only when requested in [708](https://github.com/cpp-lln-lab/bidspm/pull/708) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] convert nan to zeros in confounds in [700](https://github.com/cpp-lln-lab/bidspm/pull/700) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] change default space value in cpp_spm in [699](https://github.com/cpp-lln-lab/bidspm/pull/699) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] various bug fixes in [694](https://github.com/cpp-lln-lab/bidspm/pull/694) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] add some warnings to handle several bugs with empty ROIs in [693](https://github.com/cpp-lln-lab/bidspm/pull/693) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] re enable octave tests CI in [686](https://github.com/cpp-lln-lab/bidspm/pull/686) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] patches for [682](https://github.com/cpp-lln-lab/bidspm/pull/682) and  [683](https://github.com/cpp-lln-lab/bidspm/pull/683) (#687) by [mwmaclean](https://github.com/mwmaclean)
* [FIX] ensure that bidsResults does not run if we don't have the proper options in [679](https://github.com/cpp-lln-lab/bidspm/pull/679) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] returnRootDir only relies on fullpaths in [676](https://github.com/cpp-lln-lab/bidspm/pull/676) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] set minimum compatible fmriprep version in [675](https://github.com/cpp-lln-lab/bidspm/pull/675) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] renaming of design matrix images at group level in [668](https://github.com/cpp-lln-lab/bidspm/pull/668) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] make sure 2 sample ttest can run more than one contrasts in [665](https://github.com/cpp-lln-lab/bidspm/pull/665) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] label actiation: csv results file with no significant voxels are ignored with a warning in [663](https://github.com/cpp-lln-lab/bidspm/pull/663) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] onsets and confounds are saved in the proper dir when there are several tasks in [659](https://github.com/cpp-lln-lab/bidspm/pull/659) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] fix silent dry run override in [657](https://github.com/cpp-lln-lab/bidspm/pull/657) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] use proper subject background for montage in [656](https://github.com/cpp-lln-lab/bidspm/pull/656) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] allow extra BIDS entities to be integrated in glm dir name in [654](https://github.com/cpp-lln-lab/bidspm/pull/654) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] make GLM path more consistent in [652](https://github.com/cpp-lln-lab/bidspm/pull/652) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] prevent some crashes if Model.Input are not passed as arrays in [650](https://github.com/cpp-lln-lab/bidspm/pull/650) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] fix printing of of path  in [649](https://github.com/cpp-lln-lab/bidspm/pull/649) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] properly skip segment and sullstrip in [638](https://github.com/cpp-lln-lab/bidspm/pull/638) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] use unix format when printing path to screen in [634](https://github.com/cpp-lln-lab/bidspm/pull/634) by [Remi-Gau](https://github.com/Remi-Gau)
* [FIX] getEnvInfo for windows in [631](https://github.com/cpp-lln-lab/bidspm/pull/631) by [Remi-Gau](https://github.com/Remi-Gau)

## [2.0.0] - 2022-07-10

**Full Changelog**: https://github.com/cpp-lln-lab/bidspm/compare/v1.1.5...v2.0.0

### Added

* [DOC] prepare binder and basic jupyter notebook by [Remi-Gau](https://github.com/Remi-Gau) in [155](https://github.com/cpp-lln-lab/bidspm/pull/155)
* [DOC] general doc update by [Remi-Gau](https://github.com/Remi-Gau) in [446](https://github.com/cpp-lln-lab/bidspm/pull/446)
* [DOC] Add figures for some workflows by [Remi-Gau](https://github.com/Remi-Gau) in [463](https://github.com/cpp-lln-lab/bidspm/pull/463)
* [DOC] adds link and references to other SPM material by [Remi-Gau](https://github.com/Remi-Gau) in [464](https://github.com/cpp-lln-lab/bidspm/pull/464)
* [DOC] improve results doc and associated how to by [Remi-Gau](https://github.com/Remi-Gau) in [470](https://github.com/cpp-lln-lab/bidspm/pull/470)
* [DOC] Misc doc updates by [Remi-Gau](https://github.com/Remi-Gau) in [484](https://github.com/cpp-lln-lab/bidspm/pull/484)
* [DOC] update doc on how to filter files and what files gets upsampled by [Remi-Gau](https://github.com/Remi-Gau) in [494](https://github.com/cpp-lln-lab/bidspm/pull/494)
* [DOC] update templates by [Remi-Gau](https://github.com/Remi-Gau) in [455](https://github.com/cpp-lln-lab/bidspm/pull/455)
* [DOC] add MyST for the doc and add list of default options in the doc by [Remi-Gau](https://github.com/Remi-Gau) in [557](https://github.com/cpp-lln-lab/bidspm/pull/557)
* [DOC] update RTD with a symlink to README by [Remi-Gau](https://github.com/Remi-Gau) in [569](https://github.com/cpp-lln-lab/bidspm/pull/569)
* [DOC] fmriprep stats demo by [Remi-Gau](https://github.com/Remi-Gau) in [594](https://github.com/cpp-lln-lab/bidspm/pull/594)
* [DOC] Update getRegressorIdx.m by [Remi-Gau](https://github.com/Remi-Gau) in [601](https://github.com/cpp-lln-lab/bidspm/pull/601)
* [DOC] update where references are stored by [Remi-Gau](https://github.com/Remi-Gau) in [614](https://github.com/cpp-lln-lab/bidspm/pull/614)
* [DOC] update vismotion demo by [Remi-Gau](https://github.com/Remi-Gau) in [624](https://github.com/cpp-lln-lab/bidspm/pull/624)
* [DOC] Update FAQ and BIDS stats model related doc by [Remi-Gau](https://github.com/Remi-Gau) in [626](https://github.com/cpp-lln-lab/bidspm/pull/626)
* [ENH] adapt workflows to new bids-matlab by [Remi-Gau](https://github.com/Remi-Gau) in [368](https://github.com/cpp-lln-lab/bidspm/pull/368)
* [ENH] adapt to use fmriprep input with rshrf toolbox by [Remi-Gau](https://github.com/Remi-Gau) in [370](https://github.com/cpp-lln-lab/bidspm/pull/370)
* [ENH] add verbosity control by [Remi-Gau](https://github.com/Remi-Gau) in [381](https://github.com/cpp-lln-lab/bidspm/pull/381)
* [ENH] ROI tSNR pipeline by [Remi-Gau](https://github.com/Remi-Gau) in [401](https://github.com/cpp-lln-lab/bidspm/pull/401)
* [ENH] allow fMRIprep input for GLM by [Remi-Gau](https://github.com/Remi-Gau) in [367](https://github.com/cpp-lln-lab/bidspm/pull/367)
* [ENH] update dockerfiles by [Remi-Gau](https://github.com/Remi-Gau) in [420](https://github.com/cpp-lln-lab/bidspm/pull/420)
* [ENH] Add QA functions to plot events file and compute design efficiency by [Remi-Gau](https://github.com/Remi-Gau) in [428](https://github.com/cpp-lln-lab/bidspm/pull/428)
* [ENH] compute tSNR for a given mask by [mwmaclean](https://github.com/mwmaclean) in [402](https://github.com/cpp-lln-lab/bidspm/pull/402)
* [ENH] add a function to deinitialize CPP SPM and make sure there is just one instance in the path by [Remi-Gau](https://github.com/Remi-Gau) in [435](https://github.com/cpp-lln-lab/bidspm/pull/435)
* [ENH] Allow for multi tasks processing by [Remi-Gau](https://github.com/Remi-Gau) in [439](https://github.com/cpp-lln-lab/bidspm/pull/439)
* [ENH] Update BIDS stats model  by [Remi-Gau](https://github.com/Remi-Gau) in [441](https://github.com/cpp-lln-lab/bidspm/pull/441)
* [ENH] Enhancements subject / group level GLM and results by [Remi-Gau](https://github.com/Remi-Gau) in [443](https://github.com/cpp-lln-lab/bidspm/pull/443)
* [ENH] add elapsedTime function by [marcobarilari](https://github.com/marcobarilari) in [229](https://github.com/cpp-lln-lab/bidspm/pull/229)
* [ENH] drop support for parfor loops by [Remi-Gau](https://github.com/Remi-Gau) in [447](https://github.com/cpp-lln-lab/bidspm/pull/447)
* [ENH] reports are saved for each subject being processed by [Remi-Gau](https://github.com/Remi-Gau) in [448](https://github.com/cpp-lln-lab/bidspm/pull/448)
* [ENH] drop nifti tools dependency by [Remi-Gau](https://github.com/Remi-Gau) in [449](https://github.com/cpp-lln-lab/bidspm/pull/449)
* [ENH] add possibility to limit maximum number of volumes per run in a subject level GLM by [Remi-Gau](https://github.com/Remi-Gau) in [451](https://github.com/cpp-lln-lab/bidspm/pull/451)
* [ENH] save group stats in separate derivatives folder by [Remi-Gau](https://github.com/Remi-Gau) in [453](https://github.com/cpp-lln-lab/bidspm/pull/453)
* [ENH] improve confounds inclusion in design matrix by [Remi-Gau](https://github.com/Remi-Gau) in [454](https://github.com/cpp-lln-lab/bidspm/pull/454)
* [ENH] add metadata consistency checks by [Remi-Gau](https://github.com/Remi-Gau) in [457](https://github.com/cpp-lln-lab/bidspm/pull/457)
* [ENH] use BIDS stats model to select input task, space and override options by [Remi-Gau](https://github.com/Remi-Gau) in [461](https://github.com/cpp-lln-lab/bidspm/pull/461)
* [ENH] update roi based glm by [Remi-Gau](https://github.com/Remi-Gau) in [465](https://github.com/cpp-lln-lab/bidspm/pull/465)
* [ENH] integrates anat and func QA as part of `bidsSpatialPrepro` by [Remi-Gau](https://github.com/Remi-Gau) in [466](https://github.com/cpp-lln-lab/bidspm/pull/466)
* [ENH] create an anat only spatial preprocessing by [Remi-Gau](https://github.com/Remi-Gau) in [467](https://github.com/cpp-lln-lab/bidspm/pull/467)
* [ENH] add workflow to perform model selection using the MACS toolbox by [Remi-Gau](https://github.com/Remi-Gau) in [472](https://github.com/cpp-lln-lab/bidspm/pull/472)
* [ENH] enhancements for ROI based GLM by [Remi-Gau](https://github.com/Remi-Gau) in [477](https://github.com/cpp-lln-lab/bidspm/pull/477)
* [ENH] save jobs as m file by [Remi-Gau](https://github.com/Remi-Gau) in [482](https://github.com/cpp-lln-lab/bidspm/pull/482)
* [ENH] filter file volume by [Remi-Gau](https://github.com/Remi-Gau) in [492](https://github.com/cpp-lln-lab/bidspm/pull/492)
* [ENH] start implementing BIDS stats model transformers by [Remi-Gau](https://github.com/Remi-Gau) in [493](https://github.com/cpp-lln-lab/bidspm/pull/493)
* [ENH] Replace anat reference by bids filter by [Remi-Gau](https://github.com/Remi-Gau) in [497](https://github.com/cpp-lln-lab/bidspm/pull/497)
* [ENH] start creating main API by [Remi-Gau](https://github.com/Remi-Gau) in [511](https://github.com/cpp-lln-lab/bidspm/pull/511)
* [ENH] change verbosity levels by [Remi-Gau](https://github.com/Remi-Gau) in [507](https://github.com/cpp-lln-lab/bidspm/pull/507)
* [ENH] Add change suffix workflow by [Remi-Gau](https://github.com/Remi-Gau) in [516](https://github.com/cpp-lln-lab/bidspm/pull/516)
* [ENH] run subject level GLM with no condition by [Remi-Gau](https://github.com/Remi-Gau) in [520](https://github.com/cpp-lln-lab/bidspm/pull/520)
* [ENH] add remove dummies workflow by [Remi-Gau](https://github.com/Remi-Gau) in [521](https://github.com/cpp-lln-lab/bidspm/pull/521)
* [ENH] transformers 2 by [Remi-Gau](https://github.com/Remi-Gau) in [522](https://github.com/cpp-lln-lab/bidspm/pull/522)
* [ENH] rename output func qa by [Remi-Gau](https://github.com/Remi-Gau) in [533](https://github.com/cpp-lln-lab/bidspm/pull/533)
* [ENH] stats model and results by [Remi-Gau](https://github.com/Remi-Gau) in [541](https://github.com/cpp-lln-lab/bidspm/pull/541)
* [ENH] add workflow for creation of T1map from mp2rage by [Remi-Gau](https://github.com/Remi-Gau) in [542](https://github.com/cpp-lln-lab/bidspm/pull/542)
* [ENH] only save batches as .m files by [Remi-Gau](https://github.com/Remi-Gau) in [559](https://github.com/cpp-lln-lab/bidspm/pull/559)
* [ENH] create a BIDS app API by [Remi-Gau](https://github.com/Remi-Gau) in [564](https://github.com/cpp-lln-lab/bidspm/pull/564)
* [ENH] skullstripping fixes and options  by [Remi-Gau](https://github.com/Remi-Gau) in [571](https://github.com/cpp-lln-lab/bidspm/pull/571)
* [ENH] automatically generate method sections by [Remi-Gau](https://github.com/Remi-Gau) in [572](https://github.com/cpp-lln-lab/bidspm/pull/572)
* [ENH] fix some issue on model selection by [Remi-Gau](https://github.com/Remi-Gau) in [574](https://github.com/cpp-lln-lab/bidspm/pull/574)
* [ENH] simplify and extend bidsResults by [Remi-Gau](https://github.com/Remi-Gau) in [577](https://github.com/cpp-lln-lab/bidspm/pull/577)
* [ENH] adapt group level analysis to work with BIDS stats model by [Remi-Gau](https://github.com/Remi-Gau) in [581](https://github.com/cpp-lln-lab/bidspm/pull/581)
* [ENH] add F test by [Remi-Gau](https://github.com/Remi-Gau) in [584](https://github.com/cpp-lln-lab/bidspm/pull/584)
* [ENH] Add parametric modulation to run / subject level GLM by [Remi-Gau](https://github.com/Remi-Gau) in [585](https://github.com/cpp-lln-lab/bidspm/pull/585)
* [ENH] use native resolution for segmentation for lesion detection by [Remi-Gau](https://github.com/Remi-Gau) in [588](https://github.com/cpp-lln-lab/bidspm/pull/588)
* [ENH] add "force" parameter to bidsCopyInputFolder by [Remi-Gau](https://github.com/Remi-Gau) in [589](https://github.com/cpp-lln-lab/bidspm/pull/589)
* [ENH] add metadata to preprocessed derivatives by [Remi-Gau](https://github.com/Remi-Gau) in [580](https://github.com/cpp-lln-lab/bidspm/pull/580)
* [ENH] misc improvements at the run level GLM by [Remi-Gau](https://github.com/Remi-Gau) in [592](https://github.com/cpp-lln-lab/bidspm/pull/592)
* [ENH] improve reports by [Remi-Gau](https://github.com/Remi-Gau) in [595](https://github.com/cpp-lln-lab/bidspm/pull/595)
* [ENH] add two sample t test group level batch by [Remi-Gau](https://github.com/Remi-Gau) in [597](https://github.com/cpp-lln-lab/bidspm/pull/597)
* [ENH] allow to run "contrasts" and "results" from main API by [Remi-Gau](https://github.com/Remi-Gau) in [615](https://github.com/cpp-lln-lab/bidspm/pull/615)
* [ENH] improve group level analysis by [Remi-Gau](https://github.com/Remi-Gau) in [620](https://github.com/cpp-lln-lab/bidspm/pull/620)
* [ENH] make it possible to run models / contrasts using other columns than trial_type by [Remi-Gau](https://github.com/Remi-Gau) in [621](https://github.com/cpp-lln-lab/bidspm/pull/621)
* [ENH] add neuromorphometrics label to bidsResults output when in MNI space  by [Remi-Gau](https://github.com/Remi-Gau) in [622](https://github.com/cpp-lln-lab/bidspm/pull/622)

### Changed

* [DEP] update bids matlab by [Remi-Gau](https://github.com/Remi-Gau) in [570](https://github.com/cpp-lln-lab/bidspm/pull/570)
* [ENH] Rename preprocessing output to bids by [Remi-Gau](https://github.com/Remi-Gau) in [395](https://github.com/cpp-lln-lab/bidspm/pull/395)
* [ENH] use official HRF model from bids stats model by [Remi-Gau](https://github.com/Remi-Gau) in [604](https://github.com/cpp-lln-lab/bidspm/pull/604)
* [ENH] properly rely on BIDS stats model to specify subject level contrast by [Remi-Gau](https://github.com/Remi-Gau) in [576](https://github.com/cpp-lln-lab/bidspm/pull/576)
* [ENH] Update submodules by [Remi-Gau](https://github.com/Remi-Gau) in [575](https://github.com/cpp-lln-lab/bidspm/pull/575)
* [ENH] Bump bids matlab by [Remi-Gau](https://github.com/Remi-Gau) in [495](https://github.com/cpp-lln-lab/bidspm/pull/495)
* [ENH] drop stats folder by [Remi-Gau](https://github.com/Remi-Gau) in [539](https://github.com/cpp-lln-lab/bidspm/pull/539)
* [ENH] change MNI to SPM default IXI549Space by [Remi-Gau](https://github.com/Remi-Gau) in [456](https://github.com/cpp-lln-lab/bidspm/pull/456)

### Fixed

* [FIX] adapt to the new bids-matlab "dev" by [Remi-Gau](https://github.com/Remi-Gau) in [366](https://github.com/cpp-lln-lab/bidspm/pull/366)
* [FIX] apply [418](https://github.com/cpp-lln-lab/bidspm/pull/418) to dev by [Remi-Gau](https://github.com/Remi-Gau) in  [419](https://github.com/cpp-lln-lab/bidspm/pull/419)
* [FIX] Update binder by [Remi-Gau](https://github.com/Remi-Gau) in [413](https://github.com/cpp-lln-lab/bidspm/pull/413)
* [FIX] apply [425](https://github.com/cpp-lln-lab/bidspm/pull/425) to dev by [Remi-Gau](https://github.com/Remi-Gau) in  [426](https://github.com/cpp-lln-lab/bidspm/pull/426)
* [FIX] Fix facerep demo by [Remi-Gau](https://github.com/Remi-Gau) in [438](https://github.com/cpp-lln-lab/bidspm/pull/438)
* [FIX] make sure default BIDS models are usable by [Remi-Gau](https://github.com/Remi-Gau) in [459](https://github.com/cpp-lln-lab/bidspm/pull/459)
* [FIX] resolve issues to get anat file from a different session from the func data by [Remi-Gau](https://github.com/Remi-Gau) in [462](https://github.com/cpp-lln-lab/bidspm/pull/462)
* [FIX] returnRootDir did not return the root dir by [Remi-Gau](https://github.com/Remi-Gau) in [498](https://github.com/cpp-lln-lab/bidspm/pull/498)
* [FIX] throw error when no repetition time was found by [Remi-Gau](https://github.com/Remi-Gau) in [509](https://github.com/cpp-lln-lab/bidspm/pull/509)
* [FIX] update vismotion demo by [Remi-Gau](https://github.com/Remi-Gau) in [513](https://github.com/cpp-lln-lab/bidspm/pull/513)
* [FIX] Misc bug squashing :bug: :skull: by [Remi-Gau](https://github.com/Remi-Gau) in [515](https://github.com/cpp-lln-lab/bidspm/pull/515)
* [FIX] Fix typos in the sh run file of vismotion demo by [marcobarilari](https://github.com/marcobarilari) in [524](https://github.com/cpp-lln-lab/bidspm/pull/524)
* [FIX] fix [545](https://github.com/cpp-lln-lab/bidspm/pull/545) add more options for segmentation batch by [marcobarilari](https://github.com/marcobarilari) in  [547](https://github.com/cpp-lln-lab/bidspm/pull/547)
* [FIX] creates BIDS valid filename for ROIs in individual space by [Remi-Gau](https://github.com/Remi-Gau) in [562](https://github.com/cpp-lln-lab/bidspm/pull/562)
* [FIX] fix system test and silence ALI warning by [Remi-Gau](https://github.com/Remi-Gau) in [596](https://github.com/cpp-lln-lab/bidspm/pull/596)
* [FIX] Spatial preprocessing normalizes output of skullstripping by [Remi-Gau](https://github.com/Remi-Gau) in [602](https://github.com/cpp-lln-lab/bidspm/pull/602)
* [FIX] fix several issues for GLM at the subject level by [Remi-Gau](https://github.com/Remi-Gau) in [606](https://github.com/cpp-lln-lab/bidspm/pull/606)
* [FIX] fix several issues related to getting the correct files for the GLM by [Remi-Gau](https://github.com/Remi-Gau) in [607](https://github.com/cpp-lln-lab/bidspm/pull/607)
* [FIX] GLM: allow to filter input files based on BIDS entities for bold files by [Remi-Gau](https://github.com/Remi-Gau) in [611](https://github.com/cpp-lln-lab/bidspm/pull/611)
