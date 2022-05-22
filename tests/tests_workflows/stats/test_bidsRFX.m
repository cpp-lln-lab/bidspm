% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsRFX %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRFX_basic_rfx()

  createDummyData();

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  matlabbatch = bidsRFX('RFX', opt);

  nbGroupLevelModels = 2;
  nbBatchPerModel = 4;

  % creates 4 batches for (specify, figure, estimate, figure)
  assert(isfield(matlabbatch{1}.spm.stats, 'factorial_design'));
  assert(isfield(matlabbatch{2}.spm.util, 'print'));
  assert(isfield(matlabbatch{3}.spm.stats, 'factorial_design'));
  assert(isfield(matlabbatch{4}.spm.util, 'print'));
  assert(isfield(matlabbatch{5}.spm.stats, 'fmri_est'));
  assert(isfield(matlabbatch{6}.spm.util, 'print'));
  assert(isfield(matlabbatch{7}.spm.stats, 'fmri_est'));
  assert(isfield(matlabbatch{8}.spm.util, 'print'));
  assertEqual(numel(matlabbatch), nbGroupLevelModels * nbBatchPerModel);

  cleanUp(fullfile(opt.dir.output, 'derivatives'));

end

function test_bidsRFX_basic_smooth()

  createDummyData();

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  matlabbatch = bidsRFX('smoothContrasts', opt);
  assertEqual(numel(matlabbatch), 3); % one batch per subject

end

function test_bidsRFX_basic_mean()

  createDummyData();

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  matlabbatch =  bidsRFX('meanAnatAndMask', opt);
  assertEqual(numel(matlabbatch), 2);

end
