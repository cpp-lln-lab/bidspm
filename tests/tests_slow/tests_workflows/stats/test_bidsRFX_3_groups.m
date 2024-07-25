% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsRFX_3_groups %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRFX_one_way_anova()

  %   markTestAs('slow');
  %
  %   opt = setOptions('3_groups', '', 'pipelineType', 'stats');
  %
  %   opt.model.bm = BidsModel('file', opt.model.file);
  %   opt.verbosity = 3;
  %
  %   matlabbatch = bidsRFX('RFX', opt, 'nodeName', 'between_groups');
  %
  %   assertEqual(matlabbatch{1}.spm.stats.factorial_design.dir{1}, ...
  %               fileparts(matlabbatch{2}.spm.stats.fmri_est.spmmat{1}));
  %   assertEqual(matlabbatch{1}.spm.stats.factorial_design.dir{1}, ...
  %               matlabbatch{3}.spm.tools.MACS.MA_model_space.dir{1});
  %
  %   assertEqual(batchSummary(matlabbatch), expectedBatchOrder());

end

function test_bidsRFX_one_way_anova_contrast()

  markTestAs('slow');

  opt = setOptions('3_groups', '', 'pipelineType', 'stats');

  opt.model.bm = BidsModel('file', opt.model.file);
  opt.verbosity = 3;

  nodeName = 'between_groups';

  matlabbatch = bidsRFX('contrasts', opt, 'nodeName', nodeName);

  contrastName = 'VisMot_gt_VisStat';
  rfxDir = getRFXdir(opt, nodeName, contrastName, '1WayANOVA');
  assertEqual(fileparts(matlabbatch{1}.spm.stats.con.spmmat{1}), rfxDir);

  assertEqual(numel(matlabbatch{1}.spm.stats.con.consess), 2);
  assertEqual(matlabbatch{1}.spm.stats.con.consess{1}.tcon.convec, [0; -1; 1]);
  assertEqual(matlabbatch{1}.spm.stats.con.consess{2}.tcon.convec, [-1; 0; 1]);

  contrastName = 'VisStat_gt_VisMot';
  rfxDir = getRFXdir(opt, nodeName, contrastName, '1WayANOVA');
  assertEqual(fileparts(matlabbatch{2}.spm.stats.con.spmmat{1}), rfxDir);

  assertEqual(numel(matlabbatch{2}.spm.stats.con.consess), 2);
  assertEqual(matlabbatch{2}.spm.stats.con.consess{1}.tcon.convec, [0; -1; 1]);
  assertEqual(matlabbatch{2}.spm.stats.con.consess{2}.tcon.convec, [-1; 0; 1]);

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

  value = {'stats', 'factorial_design'; ...
           'stats', 'fmri_est'; ...
           'tools', 'MACS'; ...
           'tools', 'MACS'; ...
           'stats', 'review'; ...
           'util',  'print'};

end
