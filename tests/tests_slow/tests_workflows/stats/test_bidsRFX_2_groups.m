% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsRFX_2_groups %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
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
    assertEqual(numel(matlabbatch), 10);
  else
    assertEqual(numel(matlabbatch), 14);
  end

  % creates 1 batch for
  %   - specify
  %   - figure
  %   - estimate
  %   - MACS: model space
  %   - MACS: information criteria
  %   - review
  %   - figure
  % for each group

  batchOrder = {'stats', 'factorial_design'; ...
                'util',  'print'; ...
                'stats', 'factorial_design'; ...
                'util',  'print'};
  batchOrder = extendBatchOrder(batchOrder);
  batchOrder = extendBatchOrder(batchOrder);
  summary = batchSummary(matlabbatch);
  assertEqual(summary, batchOrder);

  [~, folder] = fileparts(matlabbatch{1}.spm.stats.factorial_design.dir{1});
  assert(bids.internal.starts_with(folder, 'sub-blind'));

  [~, folder] = fileparts(matlabbatch{3}.spm.stats.factorial_design.dir{1});
  assert(bids.internal.starts_with(folder, 'sub-ctrl'));

  assertEqual(matlabbatch{1}.spm.stats.factorial_design.dir{1}, ...
              fileparts(matlabbatch{5}.spm.stats.fmri_est.spmmat{1}));
  if bids.internal.is_octave()
    assertEqual(matlabbatch{3}.spm.stats.factorial_design.dir{1}, ...
                fileparts(matlabbatch{8}.spm.stats.fmri_est.spmmat{1}));
  else
    assertEqual(matlabbatch{3}.spm.stats.factorial_design.dir{1}, ...
                fileparts(matlabbatch{10}.spm.stats.fmri_est.spmmat{1}));
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

  summary = batchSummary(matlabbatch);

  % creates 1 batch for (specify, figure, estimate, review, figure)
  batchOrder = {'stats', 'factorial_design'; ...
                'util', 'print'};
  batchOrder = extendBatchOrder(batchOrder);
  assertEqual(summary, batchOrder);

  [~, folder] = fileparts(matlabbatch{1}.spm.stats.factorial_design.dir{1});
  assert(bids.internal.starts_with(folder, 'sub-2samplesTTest'));

  assertEqual(matlabbatch{1}.spm.stats.factorial_design.dir{1}, ...
              fileparts(matlabbatch{3}.spm.stats.fmri_est.spmmat{1}));

  % 2 blind and 1 ctrl
  assertEqual(numel(matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1), 2);
  assertEqual(numel(matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2), 1);

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
