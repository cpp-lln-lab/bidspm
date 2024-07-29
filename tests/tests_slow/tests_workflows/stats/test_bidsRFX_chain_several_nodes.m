% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsRFX_chain_several_nodes %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRFX_no_overwrite()

  markTestAs('slow');

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');
  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vismotionNoOverWrite_smdl');
  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt);

  expectedNbBatch = 79;
  if bids.internal.is_octave()
    expectedNbBatch = 5;
  end
  assertEqual(numel(matlabbatch), expectedNbBatch);

end

function test_bidsRFX_several_datasets_level()

  markTestAs('slow');

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');
  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizerSeveralDatasetLevels_smdl');
  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = bidsRFX('RFX', opt);

  summary = batchSummary(matlabbatch);

  % only the batches from the last node is returned
  % creates 1 batch for (specify, figure, estimate, review, figure)
  batchOrder = {'stats', 'factorial_design'; ...
                'util', 'print'};
  batchOrder = extendBatchOrder(batchOrder);
  assertEqual(summary, batchOrder);

  nbGroupLevelModelsReturned = 1;
  nbBatchPerModel = 7;
  if bids.internal.is_octave()
    nbBatchPerModel = 5;
  end
  assertEqual(numel(matlabbatch), nbGroupLevelModelsReturned * nbBatchPerModel);

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
