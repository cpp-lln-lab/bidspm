% (C) Copyright 2024 bidspm developers

function test_suite = test_bidsRFX_3_groups %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRFX_one_way_anova_contrast()

  opt = setOptions('3_groups', '', 'pipelineType', 'stats');

  opt.model.bm = BidsModel('file', opt.model.file);
  opt.verbosity = 0;

  nodeName = 'between_groups';

  matlabbatch = bidsRFX('contrasts', opt, 'nodeName', nodeName);

  contrastName = 'VisMot_gt_VisStat';
  rfxDir = getRFXdir(opt, nodeName, contrastName, '1WayANOVA');
  assertEqual(fileparts(matlabbatch{1}.spm.stats.con.spmmat{1}), rfxDir);

  assertEqual(numel(matlabbatch{1}.spm.stats.con.consess), 2);
  assertEqual(matlabbatch{1}.spm.stats.con.consess{1}.tcon.name, 'relative_gt_ctrl');
  assertEqual(matlabbatch{1}.spm.stats.con.consess{1}.tcon.convec, [0; -1; 1]);
  assertEqual(matlabbatch{1}.spm.stats.con.consess{2}.tcon.name, 'blind_gt_relative');
  assertEqual(matlabbatch{1}.spm.stats.con.consess{2}.tcon.convec, [-1; 0; 1]);

  contrastName = 'VisStat_gt_VisMot';
  rfxDir = getRFXdir(opt, nodeName, contrastName, '1WayANOVA');
  assertEqual(fileparts(matlabbatch{2}.spm.stats.con.spmmat{1}), rfxDir);

  assertEqual(numel(matlabbatch{2}.spm.stats.con.consess), 2);
  assertEqual(matlabbatch{1}.spm.stats.con.consess{1}.tcon.name, 'relative_gt_ctrl');
  assertEqual(matlabbatch{2}.spm.stats.con.consess{1}.tcon.convec, [0; -1; 1]);
  assertEqual(matlabbatch{1}.spm.stats.con.consess{2}.tcon.name, 'blind_gt_relative');
  assertEqual(matlabbatch{2}.spm.stats.con.consess{2}.tcon.convec, [-1; 0; 1]);

end

function test_bidsRFX_one_way_anova_results()

  opt = setOptions('3_groups', '', 'pipelineType', 'stats');

  opt.model.bm = BidsModel('file', opt.model.file);
  opt.verbosity = 3;

  nodeName = 'between_groups';

  contrastName = 'VisMot_gt_VisStat';
  rfxDir = getRFXdir(opt, nodeName, contrastName, '1WayANOVA');
  spm_mkdir(rfxDir);
  xCon(1) = struct('name', 'relative_gt_ctrl');
  xCon(2) = struct('name', 'blind_gt_relative');
  SPM = struct('nscan', 10, 'xCon', xCon);
  save(fullfile(rfxDir, 'SPM.mat'), 'SPM');

  contrastName = 'VisStat_gt_VisMot';
  rfxDir = getRFXdir(opt, nodeName, contrastName, '1WayANOVA');
  spm_mkdir(rfxDir);
  % here we switch the order of the contrast in the SPM.mat
  % to make sure the batch setting picks up the correct ones.
  xCon(2) = struct('name', 'relative_gt_ctrl');
  xCon(1) = struct('name', 'blind_gt_relative');
  SPM = struct('nscan', 10, 'xCon', xCon);
  save(fullfile(rfxDir, 'SPM.mat'), 'SPM');

  matlabbatch = bidsResults(opt, 'nodeName', nodeName);

  assertEqual(length(matlabbatch), 4);
  assertEqual(matlabbatch{1}.result.name, 'VisMotGtVisStat - relative_gt_ctrl');
  assertEqual(matlabbatch{1}.spm.stats.results.conspec.contrasts, 1);
  assertEqual(matlabbatch{2}.result.name, 'VisStatGtVisMot - relative_gt_ctrl');
  assertEqual(matlabbatch{2}.spm.stats.results.conspec.contrasts, 2);
  assertEqual(matlabbatch{3}.result.name, 'VisMotGtVisStat - blind_gt_relative');
  assertEqual(matlabbatch{3}.spm.stats.results.conspec.contrasts, 2);
  assertEqual(matlabbatch{4}.result.name, 'VisStatGtVisMot - blind_gt_relative');
  assertEqual(matlabbatch{4}.spm.stats.results.conspec.contrasts, 1);

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
