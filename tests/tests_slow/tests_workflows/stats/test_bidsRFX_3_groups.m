% (C) Copyright 2024 bidspm developers

function test_suite = test_bidsRFX_3_groups %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRFX_one_way_anova()

  markTestAs('slow');

  opt = setOptions('3_groups', '', 'pipelineType', 'stats');

  opt.model.bm = BidsModel('file', opt.model.file);
  opt.verbosity = 0;

  matlabbatch = bidsRFX('RFX', opt, 'nodeName', 'between_groups');

  assertEqual(batchSummary(matlabbatch), expectedBatchOrder());

  nodeName = 'between_groups';
  contrastName = 'VisMot_gt_VisStat';

  [~, folder] = fileparts(matlabbatch{1}.spm.stats.factorial_design.dir{1});
  assert(bids.internal.starts_with(folder, 'sub-1WayANOVA'));

  rfxDir = getRFXdir(opt, nodeName, contrastName, '1WayANOVA');
  assertEqual(matlabbatch{1}.spm.stats.factorial_design.dir{1}, rfxDir);

  assertEqual(numel(matlabbatch{1}.spm.stats.factorial_design.des.anova.icell), 3);
  assertEqual(numel(matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(1).scans), 2);
  assertEqual(fileparts(matlabbatch{5}.spm.stats.fmri_est.spmmat{1}), rfxDir);
  if ~bids.internal.is_octave
    assertEqual(matlabbatch{6}.spm.tools.MACS.MA_model_space.dir{1}, rfxDir);
  end

  nodeName = 'between_groups';
  contrastName = 'VisStat_gt_VisMot';
  rfxDir = getRFXdir(opt, nodeName, contrastName, '1WayANOVA');
  assertEqual(matlabbatch{3}.spm.stats.factorial_design.dir{1}, rfxDir);
  assertEqual(numel(matlabbatch{3}.spm.stats.factorial_design.des.anova.icell), 3);
  assertEqual(numel(matlabbatch{3}.spm.stats.factorial_design.des.anova.icell(1).scans), 2);
  assertEqual(fileparts(matlabbatch{10}.spm.stats.fmri_est.spmmat{1}), rfxDir);
  if ~bids.internal.is_octave
    assertEqual(matlabbatch{11}.spm.tools.MACS.MA_model_space.dir{1}, rfxDir);
  end

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

function value = expectedBatchOrder()

  value = {'stats',    'factorial_design'; ...
           'util',    'print'; ...
           'stats',    'factorial_design'; ...
           'util',    'print'; ...
           'stats',    'fmri_est'; ...
           'tools',    'MACS'; ...
           'tools',    'MACS'; ...
           'stats',    'review'; ...
           'util',    'print'; ...
           'stats',    'fmri_est'; ...
           'tools',    'MACS'; ...
           'tools',    'MACS'; ...
           'stats',    'review'; ...
           'util',    'print'           };

  if bids.internal.is_octave
    value = {'stats',    'factorial_design'; ...
             'util',    'print'; ...
             'stats',    'factorial_design'; ...
             'util',    'print'; ...
             'stats',    'fmri_est'; ...
             'stats',    'review'; ...
             'util',    'print'; ...
             'stats',    'fmri_est'; ...
             'stats',    'review'; ...
             'util',    'print'           };
  end

end
