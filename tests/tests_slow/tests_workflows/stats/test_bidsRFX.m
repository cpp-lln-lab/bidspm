% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsRFX %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRFX_rfx()

  markTestAs('slow');

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  matlabbatch = bidsRFX('RFX', opt);

  % 2 dummy contrasts
  % 2 contrasts
  nbGroupLevelModels = 4;
  nbBatchPerModel = 7;
  if bids.internal.is_octave()
    nbBatchPerModel = 5;
  end
  assertEqual(numel(matlabbatch), nbGroupLevelModels * nbBatchPerModel);

  summary = batchSummary(matlabbatch);

  % setBatchFactorial creates 2 batches for each model (specify, figure)
  for i = 1:2:(2 * nbGroupLevelModels)
    assertEqual(summary(i, :),   {'stats', 'factorial_design'});
    assertEqual(summary(i + 1, :), {'util',  'print'});
  end

  % setBatchEstimateModel creates 3 batches for each model (estimate, review, figure)
  batchOrder = extendBatchOrder();
  idx = 9:5:(nbGroupLevelModels * nbBatchPerModel);
  if bids.internal.is_octave()
    idx = 9:3:(nbGroupLevelModels * nbBatchPerModel);
  end
  for i = idx
    assertEqual(summary([i:i + size(batchOrder, 1) - 1], :), batchOrder); %#ok<*NBRAK>
  end

end

function test_bidsRFX_select_datasets_level_to_run()

  markTestAs('slow');

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');
  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizerSeveralDatasetLevels_smdl');
  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt, 'nodeName', 'complex contrast');

  summary = batchSummary(matlabbatch);

  % creates 1 batch for (specify, figure, estimate, review, figure)
  batchOrder = {'stats', 'factorial_design'; ...
                'util',  'print'};
  batchOrder = extendBatchOrder(batchOrder);
  assertEqual(summary, batchOrder);

  assertEqual(matlabbatch{1}.spm.stats.factorial_design.dir{1}, ...
              fileparts(matlabbatch{3}.spm.stats.fmri_est.spmmat{1}));

end

function test_bidsRFX_rfx_on_empty_dir()

  markTestAs('slow');

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');
  cleanUp(fullfile(opt.dir.output, 'derivatives'));
  matlabbatch = bidsRFX('RFX', opt);

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
  extension = {'stats', 'fmri_est'; ...
               'tools', 'MACS'; ...
               'tools', 'MACS'; ...
               'stats', 'review'; ...
               'util', 'print'};
  if bids.internal.is_octave()
    extension(2:3, :) = [];
  end
  batchOrder = cat(1, batchOrder, extension);
end

function value = batchSummary(matlabbatch)
  value = {};
  for i = 1:numel(matlabbatch)
    field = fieldnames(matlabbatch{i}.spm);
    value{i, 1} = field{1}; %#ok<*AGROW>
    field = fieldnames(matlabbatch{i}.spm.(value{i, 1}));
    value{i, 2} = field{1};
  end
end
