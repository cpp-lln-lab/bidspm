% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchSubjectLevelGLMSpec %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
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

  opt = setOptions('fmriprep-synthetic');

  opt.space = 'MNI152NLin2009cAsym';
  opt.query.space = opt.space;

  opt.pipeline.type = 'stats';

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

  opt = setOptions('vislocalizer', subLabel);

  opt.pipeline.type = 'stats';
  opt.space = {'MNI'};

  opt = dirFixture(opt);

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

  assertEqual(fieldnames(matlabbatch{1}.spm.stats.fmri_spec), expectedContent);
  assertEqual(numel(matlabbatch{1}.spm.stats.fmri_spec.sess), 2);
  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf, 125);
  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.cvi, 'FAST');
  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs, [1 0]);
  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.mthresh, 0.8);
  assertEqual(matlabbatch{1}.spm.stats.fmri_spec.mask, ...
              {fullfile(spm('dir'), 'tpm', 'mask_ICV.nii')});

  cleanUp(fullfile(pwd, 'derivatives'));

end

function test_setBatchSubjectLevelGLMSpec_design_only()

  %% GIVEN
  subLabel = '^01';

  opt = setOptions('vislocalizer', subLabel);

  opt.pipeline.type = 'stats';
  opt.space = {'MNI'};
  opt.model.designOnly = true;

  opt = dirFixture(opt);

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

function opt = dirFixture(opt)
  % required for the test
  opt.dir.raw = opt.dir.preproc;

  opt.dir.derivatives = fullfile(pwd, 'derivatives');
  opt.dir.stats = fullfile(pwd, 'derivatives', 'cpp_spm-stats');
  opt = checkOptions(opt);
end

% function expectedBatch = returnExpectedBatch()
%
%     matlabbatch{1}.spm.stats.fmri_spec.dir = { outputDir};
%
%     matlabbatch{1}.spm.stats.fmri_spec.timing.RT = RT;
%     matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = nbSlices;
%     matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = midSlice;
%
%     for iRun = 1:nbRuns
%
%         matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).scans = { boldFileForFFX};
%         matlabbatch{1}.spm.stats.fmri_spec.sess(end).multi = { eventFile };
%         matlabbatch{1}.spm.stats.fmri_spec.sess(end).multi_reg = { confoundsFile };
%
%         % Things that are unlikely to change
%         matlabbatch{1}.spm.stats.fmri_spec.sess(end).hpf = 128;
%         matlabbatch{1}.spm.stats.fmri_spec.sess(end).regress = struct( ...
%                                                                       'name', {}, ...
%                                                                       'val', {});
%         matlabbatch{1}.spm.stats.fmri_spec.sess(end).cond = struct( ...
%                                                                    'name', {}, ...
%                                                                    'onset', {}, ...
%                                                                    'duration', {}, ...
%                                                                    'tmod', {}, ...
%                                                                    'pmod', {}, ...
%                                                                    'orth', {});
%     end
%
%     % Things that may change
%     matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = opt.model.hrfDerivatives;
%
%     matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
%
%     matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
%
%     matlabbatch{1}.spm.stats.fmri_spec.cvi = 'FAST';
%
%     % Things that are unlikely to change
%     matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
%
%     matlabbatch{1}.spm.stats.fmri_spec.fact = struct( ...
%                                                      'name', {}, ...
%                                                      'levels', {});
%
%     matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
%     matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
%
% end
