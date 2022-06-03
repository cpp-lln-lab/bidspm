% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchSubjectLevelGLMSpec %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

% TODO add test to better cover setScans

function test_setBatchSubjectLevelGLMSpec_brain_mask()

  %% GIVEN
  subLabel = '^01';

  opt = setOptions('vislocalizer', subLabel, 'pipelineType', 'stats');

  opt.model.bm.Nodes{1}.Model.Options.Mask = struct('label', 'brain', 'suffix', 'mask');

  BIDS = getLayout(opt);

  %% WHEN
  matlabbatch = {};
  matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel);

  %% THEN
  assertEqual(spm_file(matlabbatch{1}.spm.stats.fmri_spec.mask, 'filename'), ...
              {'sub-01_ses-02_task-rest_space-IXI549Space_label-brain_mask.nii'});

  cleanUp(fullfile(pwd, 'derivatives'));

end

function test_setBatchSubjectLevelGLMSpec_missing_raw_data()

  subLabel = '^01';
  opt = setTestCfg();
  BIDS.pth = pwd;
  matlabbatch = {};

  assertExceptionThrown(@() setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel), ...
                        'setBatchSubjectLevelGLMSpec:missingRawDir');

end

function test_setBatchSubjectLevelGLMSpec_fmriprep()

  subLabel = '^01';

  opt = setOptions('fmriprep-synthetic', subLabel, 'pipelineType', 'stats');

  opt.space = 'MNI152NLin2009cAsym';
  opt.query.space = opt.space;

  opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');

  opt.fwhm.func = 0;

  opt = checkOptions(opt);

  matlabbatch = {};
  % bids matlab issue?
  % events.TSV are in the root of the synthetic dataset
  % matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel);

end

function test_setBatchSubjectLevelGLMSpec_basic()

  %% GIVEN
  subLabel = '^01';

  opt = setOptions('vislocalizer', subLabel, 'pipelineType', 'stats');

  BIDS = getLayout(opt);

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
  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.mthresh, 0);
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

  BIDS = getLayout(opt);

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

  BIDS = getLayout(opt);

  %% WHEN
  matlabbatch = {};
  assertExceptionThrown(@()setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel), ...
                        'getAndCheckRepetitionTime:differentRepetitionTime');

end

function test_setBatchSubjectLevelGLMSpec_design_only()

  %% GIVEN
  subLabel = '^01';

  opt = setOptions('vislocalizer', subLabel, 'pipelineType', 'stats');

  opt.model.designOnly = true;

  BIDS = getLayout(opt);

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
