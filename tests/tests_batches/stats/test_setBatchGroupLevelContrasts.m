% (C) Copyright 2021 bidspm developers

function test_suite = test_setBatchGroupLevelContrasts %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchGroupLevelContrasts_two_sample_ttest()

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizer2sampleTTest_smdl');
  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = {};
  matlabbatch = setBatchGroupLevelContrasts(matlabbatch, opt, 'between_groups');

  assertEqual(numel(matlabbatch{1}.spm.stats.con.consess), 2);
  assertEqual(matlabbatch{1}.spm.stats.con.consess{1}.tcon.name, 'blind_gt_ctrl');
  assertEqual(matlabbatch{1}.spm.stats.con.consess{1}.tcon.convec, [1; -1]);
  assertEqual(matlabbatch{1}.spm.stats.con.consess{2}.tcon.name, 'ctrl_gt_blind');
  assertEqual(matlabbatch{1}.spm.stats.con.consess{2}.tcon.convec, [-1; 1]);

end

function test_setBatchGroupLevelContrasts_within_group()

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizerWithinGroup_smdl');
  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = {};
  matlabbatch = setBatchGroupLevelContrasts(matlabbatch, opt, 'within_group');

  assertEqual(matlabbatch{1}.spm.stats.con.consess{1}.tcon.name, 'VisMot_gt_VisStat');
  dir = spm_file(spm_file(matlabbatch{1}.spm.stats.con.spmmat, 'path'), 'filename');
  assertEqual(dir, {['sub-blind_task-vislocalizer_space-IXI549Space_FWHM-6_conFWHM-0', ...
                     '_node-withinGroup_contrast-VisMotGtVisStat']});

  assertEqual(matlabbatch{2}.spm.stats.con.consess{1}.tcon.name, 'VisMot_gt_VisStat');
  dir = spm_file(spm_file(matlabbatch{2}.spm.stats.con.spmmat, 'path'), 'filename');
  assertEqual(dir, {['sub-ctrl_task-vislocalizer_space-IXI549Space_FWHM-6_conFWHM-0', ...
                     '_node-withinGroup_contrast-VisMotGtVisStat']});
end

function test_setBatchGroupLevelContrasts_basic()

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  nodeName = 'dataset_level';

  matlabbatch = {};
  matlabbatch = setBatchGroupLevelContrasts(matlabbatch, opt, nodeName);

  assertEqual(numel(matlabbatch), 4);

  assertEqual(matlabbatch{1}.spm.stats.con.consess{1}.tcon.name, 'VisMot');
  assertEqual(matlabbatch{2}.spm.stats.con.consess{1}.tcon.name, 'VisStat');
  assertEqual(matlabbatch{3}.spm.stats.con.consess{1}.tcon.name, 'VisMot_&_VisStat');
  assertEqual(matlabbatch{4}.spm.stats.con.consess{1}.tcon.name, 'VisMot_&_VisStat_lt_baseline');

end
