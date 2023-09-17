% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsRFX %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRFX_no_overwrite_smoke_test()

  markTestAs('slow');

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vismotionNoOverWrite_smdl');

  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt);

  expectedNbBatch = 8;
  if bids.internal.is_octave()
    expectedNbBatch = 7;
  end
  assertEqual(numel(matlabbatch), expectedNbBatch);

end

function test_bidsRFX_within_group_ttest()

  markTestAs('slow');

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizerWithinGroup_smdl');

  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt);

  if bids.internal.is_octave()
    assertEqual(numel(matlabbatch), 15);
  else
    assertEqual(numel(matlabbatch), 16);
  end

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

  batchOrder = {
                'stats', 'factorial_design'; ...
                'util', 'print'; ...
                'stats', 'factorial_design'; ...
                'util', 'print'
               };
  batchOrder = extendBatchOrder(batchOrder);
  batchOrder = extendBatchOrder(batchOrder);
  for idx = 1:size(batchOrder, 1)
    field = batchOrder{idx, 1};
    expected = batchOrder{idx, 2};
    assert(isfield(matlabbatch{idx}.spm.(field), expected));
  end

  assertEqual(matlabbatch{1}.spm.stats.factorial_design.dir{1}, ...
              fileparts(matlabbatch{5}.spm.stats.fmri_est.spmmat{1}));
  if bids.internal.is_octave()
    assertEqual(matlabbatch{3}.spm.stats.factorial_design.dir{1}, ...
                fileparts(matlabbatch{10}.spm.stats.fmri_est.spmmat{1}));
  else
    assertEqual(matlabbatch{3}.spm.stats.factorial_design.dir{1}, ...
                fileparts(matlabbatch{11}.spm.stats.fmri_est.spmmat{1}));
  end

end

function test_bidsRFX_two_sample_ttest()

  markTestAs('slow');

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizer2sampleTTest_smdl');

  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt);

  % creates 1 batch for (specify, figure, estimate, review, figure)
  batchOrder = {
                'stats', 'factorial_design'; ...
                'util', 'print'};
  batchOrder = extendBatchOrder(batchOrder);
  for idx = 1:size(batchOrder, 1)
    field = batchOrder{idx, 1};
    expected = batchOrder{idx, 2};
    assert(isfield(matlabbatch{idx}.spm.(field), expected));
  end

  assertEqual(matlabbatch{1}.spm.stats.factorial_design.dir{1}, ...
              fileparts(matlabbatch{3}.spm.stats.fmri_est.spmmat{1}));

  % 2 blind and 1 ctrl
  assertEqual(numel(matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1), 2);
  assertEqual(numel(matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2), 1);

end

function test_bidsRFX_select_datasets_level_to_run()

  markTestAs('slow');

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizerSeveralDatasetLevels_smdl');

  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt, 'nodeName', 'complex contrast');

  % creates 1 batch for (specify, figure, estimate, review, figure)
  batchOrder = {
                'stats', 'factorial_design'; ...
                'util', 'print'};
  batchOrder = extendBatchOrder(batchOrder);
  for idx = 1:size(batchOrder, 1)
    field = batchOrder{idx, 1};
    expected = batchOrder{idx, 2};
    assert(isfield(matlabbatch{idx}.spm.(field), expected));
  end

  assertEqual(matlabbatch{1}.spm.stats.factorial_design.dir{1}, ...
              fileparts(matlabbatch{3}.spm.stats.fmri_est.spmmat{1}));

end

function test_bidsRFX_several_datasets_level()

  markTestAs('slow');

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizerSeveralDatasetLevels_smdl');

  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt);

  % only the batches from the last node is returned
  % creates 1 batch for (specify, figure, estimate, review, figure)
  batchOrder = {
                'stats', 'factorial_design'; ...
                'util', 'print'};
  batchOrder = extendBatchOrder(batchOrder);
  for idx = 1:size(batchOrder, 1)
    field = batchOrder{idx, 1};
    expected = batchOrder{idx, 2};
    assert(isfield(matlabbatch{idx}.spm.(field), expected));
  end

  nbGroupLevelModelsReturned = 1;
  nbBatchPerModel = 8;
  if bids.internal.is_octave()
    assertEqual(numel(matlabbatch), 7);
  end
  assertEqual(numel(matlabbatch), nbGroupLevelModelsReturned * nbBatchPerModel);

end

function test_bidsRFX_rfx_on_empty_dir()

  markTestAs('slow');

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');
  cleanUp(fullfile(opt.dir.output, 'derivatives'));
  matlabbatch = bidsRFX('RFX', opt);

end

function test_bidsRFX_rfx()

  markTestAs('slow');

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  matlabbatch = bidsRFX('RFX', opt);

  % 2 dummy contrasts
  % 2 contrasts
  nbGroupLevelModels = 4;
  nbBatchPerModel = 8;
  if bids.internal.is_octave()
    nbBatchPerModel = 7;
  end
  assertEqual(numel(matlabbatch), nbGroupLevelModels * nbBatchPerModel);

  % setBatchFactorial creates 2 batches for each model (specify, figure)
  for i = 1:2:(2 * nbGroupLevelModels)
    assert(isfield(matlabbatch{i}.spm.stats, 'factorial_design'));
    assert(isfield(matlabbatch{i + 1}.spm.util, 'print'));
  end

  % setBatchEstimateModel creates 3 batches for each model (estimate, review, figure)
  batchOrder = extendBatchOrder();
  for i = 9:6:(nbGroupLevelModels * nbBatchPerModel)
    for idx = 1:size(batchOrder, 1)
      field = batchOrder{idx, 1};
      expected = batchOrder{idx, 2};
      assert(isfield(matlabbatch{i + idx - 1}.spm.(field), expected));
    end
  end

end

function test_bidsRFX_mean()

  markTestAs('slow');

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

  markTestAs('slow');

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  matlabbatch = bidsRFX('contrasts', opt);

  assertEqual(numel(matlabbatch), 4);

  assertEqual(matlabbatch{1}.spm.stats.con.consess{1}.tcon.name, 'VisMot');
  assertEqual(matlabbatch{2}.spm.stats.con.consess{1}.tcon.name, 'VisStat');
  assertEqual(matlabbatch{3}.spm.stats.con.consess{1}.tcon.name, 'VisMot_&_VisStat');
  assertEqual(matlabbatch{4}.spm.stats.con.consess{1}.tcon.name, 'VisMot_&_VisStat_lt_baseline');

end

function batchOrder = extendBatchOrder(batchOrder)
  if nargin < 1
    batchOrder = {};
  end
  extension = {
               'stats', 'fmri_est'; ...
               'tools', 'MACS'; ... % skip on octave
               'tools', 'MACS'; ...
               'tools', 'MACS'; ...
               'stats', 'review'; ...
               'util', 'print'
              };
  if bids.internal.is_octave()
    batchOrder(2, :) = [];
  end
  batchOrder = cat(1, batchOrder, extension);
end
