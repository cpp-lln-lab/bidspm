% (C) Copyright 2024 bidspm developers

function test_suite = test_bidsRFX_3_groups %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRFX_contrast()

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  matlabbatch = bidsRFX('contrasts', opt);

  assertEqual(numel(matlabbatch), 4);

  assertEqual(matlabbatch{1}.spm.stats.con.consess{1}.tcon.name, 'VisMot');
  assertEqual(matlabbatch{2}.spm.stats.con.consess{1}.tcon.name, 'VisStat');
  assertEqual(matlabbatch{3}.spm.stats.con.consess{1}.tcon.name, 'VisMot_&_VisStat');
  assertEqual(matlabbatch{4}.spm.stats.con.consess{1}.tcon.name, 'VisMot_&_VisStat_lt_baseline');

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
