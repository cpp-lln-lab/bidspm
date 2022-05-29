% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsRFX %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRFX_basic_select_datasets_level_to_run()

  createDummyData();

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizerSeveralDatasetLevels_smdl');

  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt, 'nodeName', 'complex contrast');

  % creates 1 batch for (specify, figure, estimate, figure)
  assert(isfield(matlabbatch{1}.spm.stats, 'factorial_design'));
  assert(isfield(matlabbatch{2}.spm.util, 'print'));
  assert(isfield(matlabbatch{3}.spm.stats, 'fmri_est'));
  assert(isfield(matlabbatch{4}.spm.util, 'print'));

  cleanUp(fullfile(opt.dir.output, 'derivatives'));

end

function test_bidsRFX_basic_several_datasets_level()

  createDummyData();

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizerSeveralDatasetLevels_smdl');

  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt);

  nbGroupLevelModels = 3;
  nbBatchPerModel = 4;

  % creates 2 batches for (specify, figure, estimate, figure)
  for i = 1:2:3
    assert(isfield(matlabbatch{i}.spm.stats, 'factorial_design'));
    assert(isfield(matlabbatch{i + 1}.spm.util, 'print'));
  end
  for i = 5:2:7
    assert(isfield(matlabbatch{i}.spm.stats, 'fmri_est'));
    assert(isfield(matlabbatch{i + 1}.spm.util, 'print'));
  end
  % creates 1 batch for (specify, figure, estimate, figure)
  assert(isfield(matlabbatch{9}.spm.stats, 'factorial_design'));
  assert(isfield(matlabbatch{10}.spm.util, 'print'));
  assert(isfield(matlabbatch{11}.spm.stats, 'fmri_est'));
  assert(isfield(matlabbatch{12}.spm.util, 'print'));

  assertEqual(numel(matlabbatch), nbGroupLevelModels * nbBatchPerModel);

  cleanUp(fullfile(opt.dir.output, 'derivatives'));

end

function test_bidsRFX_basic_rfx()

  createDummyData();

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  matlabbatch = bidsRFX('RFX', opt);

  nbGroupLevelModels = 4;
  nbBatchPerModel = 4;

  % creates 4 batches for (specify, figure, estimate, figure)
  for i = 1:2:7
    assert(isfield(matlabbatch{i}.spm.stats, 'factorial_design'));
    assert(isfield(matlabbatch{i + 1}.spm.util, 'print'));
  end
  for i = 9:2:15
    assert(isfield(matlabbatch{i}.spm.stats, 'fmri_est'));
    assert(isfield(matlabbatch{i + 1}.spm.util, 'print'));
  end
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
  assertEqual(numel(matlabbatch), 7);

end

function test_bidsRFX_basic_contrast()

  createDummyData();

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  matlabbatch = bidsRFX('contrast', opt);

  assertEqual(numel(matlabbatch), 4);

  assertEqual(matlabbatch{1}.spm.stats.con.consess{1}.tcon.name, 'VisMot');
  assertEqual(matlabbatch{2}.spm.stats.con.consess{1}.tcon.name, 'VisStat');
  assertEqual(matlabbatch{3}.spm.stats.con.consess{1}.tcon.name, 'VisMot_&_VisStat');
  assertEqual(matlabbatch{4}.spm.stats.con.consess{1}.tcon.name, 'VisMot_&_VisStat_lt_baseline');

end
