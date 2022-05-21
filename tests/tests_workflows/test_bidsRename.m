% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsRename %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRename_basic()

  % TODO take care of
  % - SpatialReference probably not needed for space individual if anat modality
  % - transfer of Skullstripped true, if sources has it?
  % - add Type: "brain" to skullstripping mask
  % - add sources to skullstripping output
  % - sources of std_usub-01_task-auditory_bold.nii ["sub-01/td_usub-01_task-auditory_bold.nii"]
  % - "RawSources": ["sub-01/sub-01_T1w.surf.gii"] ???
  %   Wrong raw file for normalized T1w
  % {
  %   "Description": "RECOMMENDED",
  %   "Sources": [
  %     "sub-01/sub-01_space-individual_desc-preproc_T1w.nii",
  %     "sub-01/sub-01_from-T1w_to-IXI549Space_mode-image_desc-skullstripped_xfm.nii"
  %   ],
  %   "RawSources": ["sub-01/sub-01_desc-skullstripped_T1w.nii"],
  %   "SpatialReference": {
  %     "IXI549Space": "Reference space defined by the average of the '549 subjects from the IXI dataset' linearly transformed to ICBM MNI 452."
  %   },
  %   "Resolution": [
  %     [
  %       {
  %         "r1pt0": "REQUIRED if \"res\" entity"
  %       }
  %     ]
  %   ]
  % }

  %  wrong Rawsource for sub-01_space-individual_res-r1pt0_desc-preproc_T1w.nii
  %
  % {
  %   "Description": "RECOMMENDED",
  %   "Sources": "",
  %   "RawSources": ["sub-01/sub-01_space-individual_desc-skullstripped_T1w.nii"],
  %   "SpatialReference": [
  %     ["REQUIRED if no space entity or if non standard space RECOMMENDED otherwise"]
  %   ],
  %   "Resolution": [
  %     [
  %       {
  %         "r1pt0": "REQUIRED if \"res\" entity"
  %       }
  %     ]
  %   ]
  % }

  opt = setOptions('MoAE-preproc');

  % move test data into temp directory to test renaming
  tmpDir = fullfile(pwd, 'tmp');
  if isdir(tmpDir)
    rmdir(tmpDir, 's');
  end
  spm_mkdir(tmpDir);
  copyfile(opt.dir.preproc, tmpDir);

  opt.dir.preproc = tmpDir;

  opt.dryRun = false;
  opt.verbosity = 2;

  bidsRename(opt);

end
