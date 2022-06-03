% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsRFX %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRFX_basic_select_datasets_two_sample_ttest()

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizer2sampleTTest_smdl');

  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt);

  % creates 1 batch for (specify, figure, estimate, review, figure)
  assert(isfield(matlabbatch{1}.spm.stats, 'factorial_design'));
  assert(isfield(matlabbatch{2}.spm.util, 'print'));
  assert(isfield(matlabbatch{3}.spm.stats, 'fmri_est'));
  assert(isfield(matlabbatch{4}.spm.stats, 'review'));
  assert(isfield(matlabbatch{5}.spm.util, 'print'));

  % 2 blind and 1 ctrl
  assertEqual(numel(matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1), 2);
  assertEqual(numel(matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2), 1);

  cleanUp(fullfile(opt.dir.output, 'derivatives'));

end

function test_bidsRFX_basic_select_datasets_level_to_run()

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizerSeveralDatasetLevels_smdl');

  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt, 'nodeName', 'complex contrast');

  % creates 1 batch for (specify, figure, estimate, review, figure)
  assert(isfield(matlabbatch{1}.spm.stats, 'factorial_design'));
  assert(isfield(matlabbatch{2}.spm.util, 'print'));
  assert(isfield(matlabbatch{3}.spm.stats, 'fmri_est'));
  assert(isfield(matlabbatch{4}.spm.stats, 'review'));
  assert(isfield(matlabbatch{5}.spm.util, 'print'));

  cleanUp(fullfile(opt.dir.output, 'derivatives'));

end

function test_bidsRFX_basic_several_datasets_level()

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizerSeveralDatasetLevels_smdl');

  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt);

  nbGroupLevelModels = 3;
  nbBatchPerModel = 5;

  % creates 5 batches for (specify, figure, estimate, review, figure)
  for i = 1:2:3
    assert(isfield(matlabbatch{i}.spm.stats, 'factorial_design'));
    assert(isfield(matlabbatch{i + 1}.spm.util, 'print'));
  end
  for i = 5:3:8
    assert(isfield(matlabbatch{i}.spm.stats, 'fmri_est'));
    assert(isfield(matlabbatch{i + 1}.spm.stats, 'review'));
    assert(isfield(matlabbatch{i + 2}.spm.util, 'print'));
  end
  % creates 1 batch for (specify, figure, estimate, figure)
  assert(isfield(matlabbatch{11}.spm.stats, 'factorial_design'));
  assert(isfield(matlabbatch{12}.spm.util, 'print'));
  assert(isfield(matlabbatch{13}.spm.stats, 'fmri_est'));
  assert(isfield(matlabbatch{14}.spm.stats, 'review'));
  assert(isfield(matlabbatch{15}.spm.util, 'print'));

  assertEqual(numel(matlabbatch), nbGroupLevelModels * nbBatchPerModel);

  cleanUp(fullfile(opt.dir.output, 'derivatives'));

end

function test_bidsRFX_basic_rfx()

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  matlabbatch = bidsRFX('RFX', opt);

  % 2 dummy contrasts
  % 2 contrasts
  nbGroupLevelModels = 4;
  nbBatchPerModel = 5;

  % setBatchFactorial creates 2 batches for each model (specify, figure)
  for i = 1:2:7
    assert(isfield(matlabbatch{i}.spm.stats, 'factorial_design'));
    assert(isfield(matlabbatch{i + 1}.spm.util, 'print'));
  end

  % setBatchEstimateModel creates 3 batches for each model (estimate, review, figure)
  for i = 9:3:18
    assert(isfield(matlabbatch{i}.spm.stats, 'fmri_est'));
    assert(isfield(matlabbatch{i + 1}.spm.stats, 'review'));
    assert(isfield(matlabbatch{i + 2}.spm.util, 'print'));
  end
  assertEqual(numel(matlabbatch), nbGroupLevelModels * nbBatchPerModel);

  cleanUp(fullfile(opt.dir.output, 'derivatives'));

end

function test_bidsRFX_basic_smooth()

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  matlabbatch = bidsRFX('smoothContrasts', opt);
  assertEqual(numel(matlabbatch), 3); % one batch per subject

end

function test_bidsRFX_basic_mean()

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  matlabbatch =  bidsRFX('meanAnatAndMask', opt);
  assertEqual(numel(matlabbatch), 7);

end

function test_bidsRFX_basic_contrast()

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  matlabbatch = bidsRFX('contrast', opt);

  assertEqual(numel(matlabbatch), 4);

  assertEqual(matlabbatch{1}.spm.stats.con.consess{1}.tcon.name, 'VisMot');
  assertEqual(matlabbatch{2}.spm.stats.con.consess{1}.tcon.name, 'VisStat');
  assertEqual(matlabbatch{3}.spm.stats.con.consess{1}.tcon.name, 'VisMot_&_VisStat');
  assertEqual(matlabbatch{4}.spm.stats.con.consess{1}.tcon.name, 'VisMot_&_VisStat_lt_baseline');

end
