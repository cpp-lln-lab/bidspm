% (C) Copyright 2020 bidspm developers

function test_suite = test_setBatchSubjectLevelGLMSpec %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSubjectLevelGLMSpec_design_only()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  %% GIVEN
  subLabel = '^01';

  opt = setOptions('vislocalizer', subLabel, ...
                   'pipelineType', 'stats', ...
                   'useTempDir', true);

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

end
