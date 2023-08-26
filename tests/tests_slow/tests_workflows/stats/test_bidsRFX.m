% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsRFX %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRFX_no_overwrite_smoke_test()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vismotionNoOverWrite_smdl');

  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt);

  assertEqual(numel(matlabbatch), 8);

end

function test_bidsRFX_within_group_ttest()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizerWithinGroup_smdl');

  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt);

  % creates 1 batch for
  %   - specify
  %   - figure
  %   - estimate
  %   - MACS: goodness of fit
  %   - MACS: model space
  %   - MACS: information criteria
  %   - review
  %   - figure
  % for each group
  assert(isfield(matlabbatch{1}.spm.stats, 'factorial_design'));
  assert(isfield(matlabbatch{2}.spm.util, 'print'));

  assert(isfield(matlabbatch{3}.spm.stats, 'factorial_design'));
  assert(isfield(matlabbatch{4}.spm.util, 'print'));

  assert(isfield(matlabbatch{5}.spm.stats, 'fmri_est'));
  assert(isfield(matlabbatch{6}.spm.tools, 'MACS'));
  assert(isfield(matlabbatch{7}.spm.tools, 'MACS'));
  assert(isfield(matlabbatch{8}.spm.tools, 'MACS'));
  assert(isfield(matlabbatch{9}.spm.stats, 'review'));
  assert(isfield(matlabbatch{10}.spm.util, 'print'));

  assert(isfield(matlabbatch{11}.spm.stats, 'fmri_est'));
  assert(isfield(matlabbatch{12}.spm.tools, 'MACS'));
  assert(isfield(matlabbatch{13}.spm.tools, 'MACS'));
  assert(isfield(matlabbatch{14}.spm.tools, 'MACS'));
  assert(isfield(matlabbatch{15}.spm.stats, 'review'));

  assert(isfield(matlabbatch{16}.spm.util, 'print'));

  assertEqual(matlabbatch{1}.spm.stats.factorial_design.dir{1}, ...
              fileparts(matlabbatch{5}.spm.stats.fmri_est.spmmat{1}));

  assertEqual(matlabbatch{3}.spm.stats.factorial_design.dir{1}, ...
              fileparts(matlabbatch{11}.spm.stats.fmri_est.spmmat{1}));

end

function test_bidsRFX_two_sample_ttest()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

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
  assert(isfield(matlabbatch{4}.spm.tools, 'MACS'));
  assert(isfield(matlabbatch{5}.spm.tools, 'MACS'));
  assert(isfield(matlabbatch{6}.spm.tools, 'MACS'));
  assert(isfield(matlabbatch{7}.spm.stats, 'review'));
  assert(isfield(matlabbatch{8}.spm.util, 'print'));

  assertEqual(matlabbatch{1}.spm.stats.factorial_design.dir{1}, ...
              fileparts(matlabbatch{3}.spm.stats.fmri_est.spmmat{1}));

  % 2 blind and 1 ctrl
  assertEqual(numel(matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1), 2);
  assertEqual(numel(matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2), 1);

end

function test_bidsRFX_select_datasets_level_to_run()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

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
  assert(isfield(matlabbatch{4}.spm.tools, 'MACS'));
  assert(isfield(matlabbatch{5}.spm.tools, 'MACS'));
  assert(isfield(matlabbatch{6}.spm.tools, 'MACS'));
  assert(isfield(matlabbatch{7}.spm.stats, 'review'));
  assert(isfield(matlabbatch{8}.spm.util, 'print'));

  assertEqual(matlabbatch{1}.spm.stats.factorial_design.dir{1}, ...
              fileparts(matlabbatch{3}.spm.stats.fmri_est.spmmat{1}));

end

function test_bidsRFX_several_datasets_level()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizerSeveralDatasetLevels_smdl');

  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt);

  nbGroupLevelModelsReturned = 1;
  nbBatchPerModel = 8;

  % only the batches from the last node is returned
  % creates 1 batch for (specify, figure, estimate, review, figure)
  assert(isfield(matlabbatch{1}.spm.stats, 'factorial_design'));
  assert(isfield(matlabbatch{2}.spm.util, 'print'));
  assert(isfield(matlabbatch{3}.spm.stats, 'fmri_est'));
  assert(isfield(matlabbatch{4}.spm.tools, 'MACS'));
  assert(isfield(matlabbatch{5}.spm.tools, 'MACS'));
  assert(isfield(matlabbatch{6}.spm.tools, 'MACS'));
  assert(isfield(matlabbatch{7}.spm.stats, 'review'));
  assert(isfield(matlabbatch{8}.spm.util, 'print'));

  assertEqual(numel(matlabbatch), nbGroupLevelModelsReturned * nbBatchPerModel);

end

function test_bidsRFX_rfx_on_empty_dir()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');
  cleanUp(fullfile(opt.dir.output, 'derivatives'));
  matlabbatch = bidsRFX('RFX', opt);

end

function test_bidsRFX_rfx()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  matlabbatch = bidsRFX('RFX', opt);

  % 2 dummy contrasts
  % 2 contrasts
  nbGroupLevelModels = 4;
  nbBatchPerModel = 8;

  % setBatchFactorial creates 2 batches for each model (specify, figure)
  for i = 1:2:(2 * nbGroupLevelModels)
    assert(isfield(matlabbatch{i}.spm.stats, 'factorial_design'));
    assert(isfield(matlabbatch{i + 1}.spm.util, 'print'));
  end

  % setBatchEstimateModel creates 3 batches for each model (estimate, review, figure)
  for i = 9:6:(nbGroupLevelModels * nbBatchPerModel)
    assert(isfield(matlabbatch{i}.spm.stats, 'fmri_est'));
    assert(isfield(matlabbatch{i + 1}.spm.tools, 'MACS'));
    assert(isfield(matlabbatch{i + 2}.spm.tools, 'MACS'));
    assert(isfield(matlabbatch{i + 3}.spm.tools, 'MACS'));
    assert(isfield(matlabbatch{i + 4}.spm.stats, 'review'));
    assert(isfield(matlabbatch{i + 5}.spm.util, 'print'));
  end
  assertEqual(numel(matlabbatch), nbGroupLevelModels * nbBatchPerModel);

end

function test_bidsRFX_mean()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  matlabbatch =  bidsRFX('meanAnatAndMask', opt);
  assertEqual(fieldnames(matlabbatch{1}.spm.util), {'imcalc'});
  assertEqual(fieldnames(matlabbatch{2}.spm.util), {'imcalc'});
  assertEqual(fieldnames(matlabbatch{3}.spm.spatial), {'smooth'});
  assertEqual(fieldnames(matlabbatch{4}.spm.util), {'imcalc'});
  assertEqual(fieldnames(matlabbatch{5}), {'cfg_basicio'});
  assertEqual(fieldnames(matlabbatch{6}.spm.util), {'checkreg'});
  assertEqual(numel(matlabbatch), 6);

end

function test_bidsRFX_contrast()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  matlabbatch = bidsRFX('contrasts', opt);

  assertEqual(numel(matlabbatch), 4);

  assertEqual(matlabbatch{1}.spm.stats.con.consess{1}.tcon.name, 'VisMot');
  assertEqual(matlabbatch{2}.spm.stats.con.consess{1}.tcon.name, 'VisStat');
  assertEqual(matlabbatch{3}.spm.stats.con.consess{1}.tcon.name, 'VisMot_&_VisStat');
  assertEqual(matlabbatch{4}.spm.stats.con.consess{1}.tcon.name, 'VisMot_&_VisStat_lt_baseline');

end
