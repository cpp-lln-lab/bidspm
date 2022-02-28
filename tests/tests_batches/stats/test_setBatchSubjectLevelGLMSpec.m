% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchSubjectLevelGLMSpec %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

% TODO add test to better cover setScans

function test_setBatchSubjectLevelGLMSpec_missing_raw_data()

  subLabel = '^01';
  opt = setTestCfg();
  BIDS.pth = pwd;
  matlabbatch = {};

  assertExceptionThrown(@() setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel), ...
                        'setBatchSubjectLevelGLMSpec:missingRawDir');

end

function test_setBatchSubjectLevelGLMSpec_fmriprep()
  
  % TODO
  return

  subLabel = '^01';

  opt = setOptions('fmriprep-synthetic', subLabel, 'pipelineType', 'stats');

  opt.space = 'MNI152NLin2009cAsym';
  opt.query.space = opt.space;

  opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');

  opt.fwhm.func = 0;

  opt = checkOptions(opt);

  % No proper valid bids file in derivatives of synthetic dataset

  %   [BIDS, opt] = getData(opt, opt.dir.input);
  %
  %   matlabbatch = {};
  %   matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel);

end

function test_setBatchSubjectLevelGLMSpec_basic()

  %% GIVEN
  subLabel = '^01';

  opt = setOptions('vislocalizer', subLabel, 'pipelineType', 'stats');

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  %% WHEN
  matlabbatch = {};
  matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel);

  %% THEN
  expectedContent = {'volt'
                     'global'
                     'timing'
                     'dir'
                     'fact'
                     'mthresh'
                     'bases'
                     'cvi'
                     'sess'
                     'mask'};

  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.volt,  1);
  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.global, 'None');

  assertEqual(fieldnames(matlabbatch{1}.spm.stats.fmri_spec), expectedContent);
  assertEqual(numel(matlabbatch{1}.spm.stats.fmri_spec.sess), 2);
  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf, 125);
  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.cvi, 'FAST');
  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs, [1 0]);
  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.mthresh, 0.8);
  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.mask, ...
              {fullfile(spm('dir'), 'tpm', 'mask_ICV.nii')});

  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.timing.units, 'secs');
  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.timing.RT, 1.55);

  cleanUp(fullfile(pwd, 'derivatives'));

end

function test_setBatchSubjectLevelGLMSpec_slicetiming_metadata()

  %% GIVEN
  subLabel = '^01';

  opt = setOptions('vismotion', subLabel, 'pipelineType', 'stats');

  opt.query.acq = '';

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  %% WHEN
  matlabbatch = {};
  matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel);

  %% THEN
  assertEqual(numel(matlabbatch{1}.spm.stats.fmri_spec.sess), 4);
  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t,  14);
  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0, 7);

  cleanUp(fullfile(pwd, 'derivatives'));

end

function test_setBatchSubjectLevelGLMSpec_inconsistent_metadata()

  %% GIVEN
  subLabel = '^01';

  opt = setOptions({'vismotion', 'vislocalizer'}, subLabel, ...
                   'pipelineType', 'stats');

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  %% WHEN
  matlabbatch = {};
  assertExceptionThrown( ...
                        @()setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel), ...
                        'getAndCheckRepetitionTime:differentRepetitionTime');

end

function test_setBatchSubjectLevelGLMSpec_design_only()

  %% GIVEN
  subLabel = '^01';

  opt = setOptions('vislocalizer', subLabel, 'pipelineType', 'stats');

  opt.model.designOnly = true;

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  %% WHEN
  matlabbatch = {};
  matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel);

  %% THEN
  expectedContent = {'volt'
                     'global'
                     'timing'
                     'dir'
                     'fact'
                     'mthresh'
                     'bases'
                     'cvi'
                     'sess'};

  assertEqual(fieldnames(matlabbatch{1}.spm.stats.fmri_design), expectedContent);
  assertEqual(numel(matlabbatch{1}.spm.stats.fmri_design.sess), 2);
  assertEqual(matlabbatch{1}.spm.stats.fmri_design.sess(1).hpf, 125);
  assertEqual(matlabbatch{1}.spm.stats.fmri_design.cvi, 'FAST');
  assertEqual(matlabbatch{1}.spm.stats.fmri_design.bases.hrf.derivs, [1 0]);

  cleanUp(fullfile(pwd, 'derivatives'));

end

% function expectedBatch = returnExpectedBatch()
%
%
%     for iRun = 1:nbRuns
%
%         matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).scans = { boldFileForFFX};
%         matlabbatch{1}.spm.stats.fmri_spec.sess(end).multi = { eventFile };
%         matlabbatch{1}.spm.stats.fmri_spec.sess(end).multi_reg = { confoundsFile };
%
%     end
%
%
% end
