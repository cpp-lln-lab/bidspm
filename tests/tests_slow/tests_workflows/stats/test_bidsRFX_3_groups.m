% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsRFX_3_groups %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRFX_two_sample_ttest()

  markTestAs('slow');

  opt = setOptions('3_groups', '', 'pipelineType', 'stats');

  opt.model.bm = BidsModel('file', opt.model.file);
  opt.verbosity = 3;

  matlabbatch = bidsRFX('RFX', opt, 'nodeName', 'between_groups');

  assertEqual(matlabbatch{1}.spm.stats.factorial_design.dir{1}, ...
              fileparts(matlabbatch{2}.spm.stats.fmri_est.spmmat{1}));
  assertEqual(matlabbatch{1}.spm.stats.factorial_design.dir{1}, ...
              matlabbatch{3}.spm.tools.MACS.MA_model_space.dir{1});

  summary = batchSummary(matlabbatch);

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
