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

<!-- **Full Changelog**: https://github.com/cpp-lln-lab/CPP_SPM/compare/v3.0.0...v3.1.0 -->

### Added

* [DOC] minor doc fixes (#1020) @Remi-Gau
* [DOC] Improve doc example out stats (#1014) @Remi-Gau
* [DOC] update doc regarding FAST model as default (#985) @Remi-Gau
* [DOC] update contributors and default options in doc (#981) @Remi-Gau
* [DOC] add doc to link to transformations (#942) @Remi-Gau
* [DOC] add demo code from workshop (#935) @Remi-Gau
* [DOC] abstract OHBM 2023 (#934) @Remi-Gau
* [DOC] add argument groups to python cli (#907) @Remi-Gau
* [DOC] update FAQ (#897) @Remi-Gau
* [ENH] add proper error when a column cannot be found in participants.tsv (#1050) @Remi-Gau
* [ENH] update CPP ROI and add methods section for ROI creation (#1026) @Remi-Gau
* [ENH] update rename to store original spm name of a file in metadata (#987) @Remi-Gau
* [ENH] add hemisphere parameter to CLI (#950) @Remi-Gau
* [ENH] make it possible to update bidspm from any folder (#948) @Remi-Gau
* [ENH] use filtering of layout (#944) @Remi-Gau
* [ENH] make reports more silent (#939) @Remi-Gau
* [ENH] Add CC0 license by default to all outputs (#898) @Remi-Gau

### Changed

* [ENH] overwrite files when renaming by default (#1051) @Remi-Gau
* [ENH] turn error into warning when no data to copy found (#992) @Remi-Gau

### Deprecated

### Removed

* [ENH] drop rsHRF support (#906) @Remi-Gau

### Fixed

* [FIX] handle phase entity in filename (#1034) @Remi-Gau
* [FIX] fix group level results after contrasts smoothing  (#1021) @Remi-Gau
* [FIX] copy to derivatives handles bids filter file and minimize re copying files that already exist (#1015) @Remi-Gau
* [FIX] allow cli to run constrat smoothing (#1012) @Remi-Gau
* [FIX] Force copy of data from fmriprep folder even if bidspm-preproc folder exists (#1009) @marcobarilari
* [FIX] report proper fold number in labelfold.tsv (#989) @Remi-Gau
* [FIX] inconsistent slice timing throw errors and not warnings (#982) @Remi-Gau
* [FIX] validate condition names early to avoid downstream error (#983) @Remi-Gau
* [FIX] validate content results structure (#980) @Remi-Gau
* [FIX] missing variable for a Filter transform should not lead to a crash (#970) @Remi-Gau
* [FIX] display error when impossible slice timing values are given (#969) @Remi-Gau
* [FIX] fix QA failures (#941) @Remi-Gau
* [FIX] bug fix 892 (#936) @Remi-Gau
* [FIX] fix python cli (#888) @Remi-Gau

## [3.0.0] - 2022-12-14

**Full Changelog**: https://github.com/cpp-lln-lab/CPP_SPM/compare/v2.3.0...v3.0.0

### Changed

* [DEP] deprecate slice order in options (#882) @Remi-Gau
* [ENH] change the way parametric models are run (#873) @Remi-Gau*

## Added

* [ENH] include roi based calls in CLI  (#880) @Remi-Gau
* [ENH] add copy dataset to CLI (#842) @Remi-Gau
* [ENH] add smoothing to CLI (#841) @Remi-Gau
* [ENH] create docker image of bids app - Octave (#837) @Remi-Gau
* [ENH] use python based CLI to run bidspm with octave (#832) @Remi-Gau
* [ENH] update CPP_ROI (#885) @Remi-Gau
* [ENH] add extra files to derivatives datasets (#883) @Remi-Gau
* [ENH] incorporate opt.results in bids stats model (#879) @Remi-Gau
* [ENH] add option to ignore creating dataset level node in default model (#871) @Remi-Gau
* [ENH] implement logger (#867) @Remi-Gau
* [ENH] add function to return contrast filename for a certain contrast name (#866) @Remi-Gau
* [DOC] update FAQ to explain how to change subject level GLM folder name (#872) @Remi-Gau

## Fixed

* [FIX] better handle metadata when changing suffix (#884) @Remi-Gau
* [FIX] exit with a warning and not an error when no contrast specified (#870) @Remi-Gau
* [FIX] fix SPM loading in returnContrastImageFile (#869) @Remi-Gau
* [FIX] fix make file (#868) @Remi-Gau

## [2.3.0] - 2022-11-22

**Full Changelog**: https://github.com/cpp-lln-lab/CPP_SPM/compare/v2.2.0...v2.3.0

- `bidspm` main function:
  - saving options are saved to help with bug report
  - generate method section in reports folder when running preprocess or statistics

### Added

* [DOC] add auto label of activation info (#821) @Remi-Gau
* [DOC] improve bids model warning (#820) @Remi-Gau
* [DOC] add all functions to doc (#819) @Remi-Gau
* [ENH] add design only to CLI #772
* [ENH] smoothing workflow will also try to smooth the corresponding anat data too
* [ENH] save skipped ROIs and concat beta maps (#823) @Remi-Gau
* [ENH] add boilerplate to CLI (#822) @Remi-Gau
* [ENH] error logs are generated upon crash for better bug reports (#808) @Remi-Gau
* [ENH] Use CLI to create default model (#804) @Remi-Gau
* [ENH] include bids and bids stats model validation if the validators are installed (#787) @Remi-Gau
* [ENH] add inverse normalize workflow (#784) @Remi-Gau
* [ENH] lesion detection will be done by including the CSF TPM too (#778) @Remi-Gau

### Fixed

* [FIX] fix printing of windows path (#812) @Remi-Gau
* [FIX] use glob patterns to define dummy contrasts (#826) @Remi-Gau
* [FIX] rm desc when renamining some files in lesion segemtation (#817) @Remi-Gau
* [FIX] avoid duplicate contrasts (#816) @Remi-Gau
* [FIX] make collecting of OS version on windows more robust (#806) @Remi-Gau
* [FIX] throw warning when no results are asked (#795) @Remi-Gau
* [FIX] fix windows bugs (#792) @Remi-Gau
* [FIX] fix spelling (#789) @Remi-Gau
* [FIX] fix and tidy failing workflows (#774) @Remi-Gau

## [2.2.0] - 2022-10-29

**Full Changelog**: https://github.com/cpp-lln-lab/CPP_SPM/compare/v2.1.0...v2.2.0

### Added

* [DOC] use new copyright format (#750) @Remi-Gau
* [DOC] improve stats doc and warnings (#746) @Remi-Gau
* [ENH] add design only to CLI (#772) @Remi-Gau
* [ENH] add functions to help select fmriprep regressors (#748) @Remi-Gau
* [ENH] start switching to bidspm (#747) @Remi-Gau
* [ENH] use inputs from several datasets for lesion abnormality detection (#730) @Remi-Gau
* [ENH] Update bidspm path (#752) @Remi-Gau

### Changed

* [DEP] update bids matlab (#734) @Remi-Gau

### Fixed

* [FIX] fixes workflow timing (#773) @Remi-Gau
* [FIX] related to #763 and testing through CI if the patch breaks things (reopened) (#765) @marcobarilari

## [2.1.0] - 2022-07-21

**Full Changelog**: https://github.com/cpp-lln-lab/CPP_SPM/compare/v2.0.0...v2.0.1

### Added

* [ENH] add possibility to use AAL for labelling of activations (#717) @Remi-Gau
* [DOC] update FAQ to help structure data to run stats on fmriprep (#685) @Remi-Gau
* [DOC] add demo for ds002799 (#678) @Remi-Gau
* [DOC] add DIY section to documtation (#677) @Remi-Gau
* [DOC] improve description of stats output and of bids stats model (#670) @Remi-Gau

### Changed

* [MNT] update citation file (#721) @Remi-Gau
* [DEP] update bids matlab (#680) @Remi-Gau

### Fixed

* [FIX] fix lesion segmentation output (and refactor) (#727) @Remi-Gau
* [FIX] add more explicit error message for input parsing of getData (#726) @Remi-Gau
* [FIX] support globbing patterns to specify conditions in design matrix (#716) @Remi-Gau
* [FIX] fix ALI toolbox issues (#723) @Remi-Gau
* [FIX] improve warning selecting too many masks (#715) @Remi-Gau
* [FIX] fix and refactor demos, and update help sections (#701) @Remi-Gau
* [FIX] add guard clauses to run ROI based analysis only when requested (#708) @Remi-Gau
* [FIX] convert nan to zeros in confounds (#700) @Remi-Gau
* [FIX] change default space value in cpp_spm (#699) @Remi-Gau
* [FIX] various bug fixes (#694) @Remi-Gau
* [FIX] add some warnings to handle several bugs with empty ROIs (#693) @Remi-Gau
* [FIX] re enable octave tests CI (#686) @Remi-Gau
* [FIX] patches for #682 and #683 (#687) @mwmaclean
* [FIX] ensure that bidsResults does not run if we don't have the proper options (#679) @Remi-Gau
* [FIX] returnRootDir only relies on fullpaths (#676) @Remi-Gau
* [FIX] set minimum compatible fmriprep version (#675) @Remi-Gau
* [FIX] renaming of design matrix images at group level (#668) @Remi-Gau
* [FIX] make sure 2 sample ttest can run more than one contrasts (#665) @Remi-Gau
* [FIX] label actiation: csv results file with no significant voxels are ignored with a warning (#663) @Remi-Gau
* [FIX] onsets and confounds are saved in the proper dir when there are several tasks (#659) @Remi-Gau
* [FIX] fix silent dry run override (#657) @Remi-Gau
* [FIX] use proper subject background for montage (#656) @Remi-Gau
* [FIX] allow extra BIDS entities to be integrated in glm dir name (#654) @Remi-Gau
* [FIX] make GLM path more consistent (#652) @Remi-Gau
* [FIX] prevent some crashes if Model.Input are not passed as arrays (#650) @Remi-Gau
* [FIX] fix printing of of path  (#649) @Remi-Gau
* [FIX] properly skip segment and sullstrip (#638) @Remi-Gau
* [FIX] use unix format when printing path to screen (#634) @Remi-Gau
* [FIX] getEnvInfo for windows (#631) @Remi-Gau

## [2.0.0] - 2022-07-10

**Full Changelog**: https://github.com/cpp-lln-lab/CPP_SPM/compare/v1.1.5...v2.0.0

### Added

* [DOC] prepare binder and basic jupyter notebook by @Remi-Gau in #155
* [DOC] general doc update by @Remi-Gau in #446
* [DOC] Add figures for some workflows by @Remi-Gau in #463
* [DOC] adds link and references to other SPM material by @Remi-Gau in #464
* [DOC] improve resuls doc and associated how to by @Remi-Gau in #470
* [DOC] Misc doc updates by @Remi-Gau in #484
* [DOC] update doc on how to filter files and what files gets upsampled by @Remi-Gau in #494
* [DOC] update templates by @Remi-Gau in #455
* [DOC] add MyST for the doc and add list of default options in the doc by @Remi-Gau in #557
* [DOC] update RTD with a symlink to README by @Remi-Gau in #569
* [DOC] fmriprep stats demo by @Remi-Gau in #594
* [DOC] Update getRegressorIdx.m by @Remi-Gau in #601
* [DOC] update where references are stored by @Remi-Gau in #614
* [DOC] update vismotion demo by @Remi-Gau in #624
* [DOC] Update FAQ and BIDS stats model related doc by @Remi-Gau in #626
* [ENH] adapt workflows to new bids-matlab by @Remi-Gau in #368
* [ENH] adapt to use fmriprep input with rshrf toolbox by @Remi-Gau in #370
* [ENH] add verbosity control by @Remi-Gau in #381
* [ENH] ROI tSNR pipeline by @Remi-Gau in #401
* [ENH] allow fMRIprep input for GLM by @Remi-Gau in #367
* [ENH] update dockerfiles by @Remi-Gau in #420
* [ENH] Add QA functions to plot events file and compute design efficiency by @Remi-Gau in #428
* [ENH] compute tSNR for a given mask by @mwmaclean in #402
* [ENH] add a function to deinitialize CPP SPM and make sure there is just one instance in the path by @Remi-Gau in #435
* [ENH] Allow for multi tasks processing by @Remi-Gau in #439
* [ENH] Update BIDS stats model  by @Remi-Gau in #441
* [ENH] Enhancements subject / group level GLM and results by @Remi-Gau in #443
* [ENH] add elapsedTime function by @marcobarilari in #229
* [ENH] drop support for parfor loops by @Remi-Gau in #447
* [ENH] reports are saved for each subject being processed by @Remi-Gau in #448
* [ENH] drop nifti tools dependency by @Remi-Gau in #449
* [ENH] add possibility to limit maximum number of volumes per run in a subject level GLM by @Remi-Gau in #451
* [ENH] save group stats in separate derivatives folder by @Remi-Gau in #453
* [ENH] improve confounds inclusion in design matrix by @Remi-Gau in #454
* [ENH] add metadata consistency checks by @Remi-Gau in #457
* [ENH] use BIDS stats model to select input task, space and override options by @Remi-Gau in #461
* [ENH] update roi based glm by @Remi-Gau in #465
* [ENH] integrates anat and func QA as part of `bidsSpatialPrepro` by @Remi-Gau in #466
* [ENH] create an anat only spatial preprocessing by @Remi-Gau in #467
* [ENH] add workflow to perform model selection using the MACS toolbox by @Remi-Gau in #472
* [ENH] enhancements for ROI based GLM by @Remi-Gau in #477
* [ENH] save jobs as m file by @Remi-Gau in #482
* [ENH] filter file volume by @Remi-Gau in #492
* [ENH] start implementing BIDS stats model transformers by @Remi-Gau in #493
* [ENH] Replace anat reference by bids filter by @Remi-Gau in #497
* [ENH] start creating main API by @Remi-Gau in #511
* [ENH] change verbosity levels by @Remi-Gau in #507
* [ENH] Add change suffix workflow by @Remi-Gau in #516
* [ENH] run subject level GLM with no condition by @Remi-Gau in #520
* [ENH] add remove dummies workflow by @Remi-Gau in #521
* [ENH] transformers 2 by @Remi-Gau in #522
* [ENH] rename output func qa by @Remi-Gau in #533
* [ENH] stats model and results by @Remi-Gau in #541
* [ENH] add workflow for creation of T1map from mp2rage by @Remi-Gau in #542
* [ENH] only save batches as .m files by @Remi-Gau in #559
* [ENH] create a BIDS app API by @Remi-Gau in #564
* [ENH] skullstripping fixes and options  by @Remi-Gau in #571
* [ENH] automatically generate method sections by @Remi-Gau in #572
* [ENH] fix some issue on model selection by @Remi-Gau in #574
* [ENH] simplify and extend bidsResults by @Remi-Gau in #577
* [ENH] adapt group level analysis to work with BIDS stats model by @Remi-Gau in #581
* [ENH] add F test by @Remi-Gau in #584
* [ENH] Add parametric modulation to run / subject level GLM by @Remi-Gau in #585
* [ENH] use native resolution for segmentation for lesion detection by @Remi-Gau in #588
* [ENH] add "force" parameter to bidsCopyInputFolder by @Remi-Gau in #589
* [ENH] add metadata to preprocessed derivatives by @Remi-Gau in #580
* [ENH] misc improvements at the run level GLM by @Remi-Gau in #592
* [ENH] improve reports by @Remi-Gau in #595
* [ENH] add two sample t test group level batch by @Remi-Gau in #597
* [ENH] allow to run "contrasts" and "results" from main API by @Remi-Gau in #615
* [ENH] improve group level analysis by @Remi-Gau in #620
* [ENH] make it possible to run models / contrasts using other columns than trial_type by @Remi-Gau in #621
* [ENH] add neuromorphometrics label to bidsResults output when in MNI space  by @Remi-Gau in #622

### Changed

* [DEP] update bids matlab by @Remi-Gau in #570
* [ENH] Rename preprocessing output to bids by @Remi-Gau in #395
* [ENH] use official HRF model from bids stats model by @Remi-Gau in #604
* [ENH] properly rely on BIDS stats model to specify subject level contrast by @Remi-Gau in #576
* [ENH] Update submodules by @Remi-Gau in #575
* [ENH] Bump bids matlab by @Remi-Gau in #495
* [ENH] drop stats folder by @Remi-Gau in #539
* [ENH] change MNI to SPM default IXI549Space by @Remi-Gau in #456

### Fixed

* [FIX] adapt to the new bids-matlab "dev" by @Remi-Gau in #366
* [FIX] apply #418 to dev by @Remi-Gau in #419
* [FIX] Update binder by @Remi-Gau in #413
* [FIX] apply #425 to dev by @Remi-Gau in #426
* [FIX] Fix facerep demo by @Remi-Gau in #438
* [FIX] make sure default BIDS models are usable by @Remi-Gau in #459
* [FIX] reolve issues to get anat file from a different session from the func data by @Remi-Gau in #462
* [FIX] returnRootDir did not return the root dir by @Remi-Gau in #498
* [FIX] throw error when no repetition time was found by @Remi-Gau in #509
* [FIX] update vismotion demo by @Remi-Gau in #513
* [FIX] Misc bug squashing :bug: :skull: by @Remi-Gau in #515
* [FIX] Fix typos in the sh run file of vismotion demo by @marcobarilari in #524
* [FIX] fix #545 add more options for segmentation batch by @marcobarilari in #547
* [FIX] creates BIDS valid filename for ROIs in individual space by @Remi-Gau in #562
* [FIX] fix system test and silence ALI warning by @Remi-Gau in #596
* [FIX] Spatial preprocessing normalizes output of skullstripping by @Remi-Gau in #602
* [FIX] fix several issues for GLM at the subject level by @Remi-Gau in #606
* [FIX] fix several issues related to getting the correct files for the GLM by @Remi-Gau in #607
* [FIX] GLM: allow to filter input files based on BIDS entities for bold files by @Remi-Gau in #611
