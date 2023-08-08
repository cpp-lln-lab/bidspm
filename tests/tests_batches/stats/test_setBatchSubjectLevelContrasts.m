% (C) Copyright 2020 bidspm developers

function test_suite = test_setBatchSubjectLevelContrasts %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSubjectLevelContrasts_F_contrast()

  subLabel = '01';

  opt = setOptions('vismotion', subLabel, 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, 'basename', 'model-vismotionFtest_smdl');
  opt.model.bm = BidsModel('file', opt.model.file);

  matlabbatch = {};
  matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel);

  con.spmmat = {fullfile(opt.dir.stats, ...
                         'sub-01', ...
                         'task-vismotion_space-IXI549Space_FWHM-6', ...
                         'SPM.mat')};
  con.delete = 1;

  consess{1}.tcon.name = 'VisMot_gt_VisStat_ses-01'; %#ok<*AGROW>
  consess{1}.tcon.convec = [1 -1 0 0 0 0 0 0 0];
  consess{1}.tcon.sessrep = 'none';

  consess{2}.fcon.name = 'F_test_mot_static_ses-01'; %#ok<*AGROW>
  consess{2}.fcon.convec = [1 0 0 0 0 0 0 0 0
                            0 1 0 0 0 0 0 0 0];
  consess{2}.fcon.sessrep = 'none';

  con.consess = consess;

  assertEqual(matlabbatch{1}.spm.stats.con, con);

end

function test_setBatchSubjectLevelContrasts_basic()

  subLabel = '01';

  opt = setOptions('vismotion', subLabel, 'pipelineType', 'stats');

  matlabbatch = {};
  matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel);

  con.spmmat = {fullfile(opt.dir.stats, ...
                         'sub-01', ...
                         'task-vismotion_space-IXI549Space_FWHM-6', ...
                         'SPM.mat')};
  con.delete = 1;

  consess{1}.tcon.name = 'VisMot_ses-01'; %#ok<*AGROW>
  consess{end}.tcon.convec = [1 0 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  consess{end + 1}.tcon.name = 'VisStat_ses-01'; %#ok<*AGROW>
  consess{end}.tcon.convec = [0 1 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  consess{end + 1}.tcon.name = 'VisMot_gt_VisStat_ses-01'; %#ok<*AGROW>
  consess{end}.tcon.convec = [1 -1 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  consess{end + 1}.tcon.name = 'VisStat_gt_VisMot_ses-01'; %#ok<*AGROW>
  consess{end}.tcon.convec = [-1 1 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  consess{end + 1}.tcon.name = 'VisMot'; %#ok<*AGROW>
  consess{end}.tcon.convec = [1 0 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  consess{end + 1}.tcon.name = 'VisStat'; %#ok<*AGROW>
  consess{end}.tcon.convec = [0 1 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  consess{end + 1}.tcon.name = 'VisMot_gt_VisStat'; %#ok<*AGROW>
  consess{end}.tcon.convec = [1 -1 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  consess{end + 1}.tcon.name = 'VisStat_gt_VisMot'; %#ok<*AGROW>
  consess{end}.tcon.convec = [-1 1 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  con.consess = consess;

  for i = 1:numel(matlabbatch{1}.spm.stats.con.consess)
    assertEqual(matlabbatch{1}.spm.stats.con.consess{i}.tcon, ...
                con.consess{i}.tcon);
  end
  assertEqual(matlabbatch{1}.spm.stats.con, con);

end

function test_setBatchSubjectLevelContrasts_select_node()

  subLabel = '01';

  opt = setOptions('vismotion', subLabel, 'pipelineType', 'stats');

  matlabbatch = {};
  matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel, 'subject_level');

  con.spmmat = {fullfile(opt.dir.stats, ...
                         'sub-01', ...
                         'task-vismotion_space-IXI549Space_FWHM-6', ...
                         'SPM.mat')};
  con.delete = 1;

  consess{1}.tcon.name = 'VisMot'; %#ok<*AGROW>
  consess{end}.tcon.convec = [1 0 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  consess{end + 1}.tcon.name = 'VisStat'; %#ok<*AGROW>
  consess{end}.tcon.convec = [0 1 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  consess{end + 1}.tcon.name = 'VisMot_gt_VisStat'; %#ok<*AGROW>
  consess{end}.tcon.convec = [1 -1 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  consess{end + 1}.tcon.name = 'VisStat_gt_VisMot'; %#ok<*AGROW>
  consess{end}.tcon.convec = [-1 1 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  con.consess = consess;

  assertEqual(matlabbatch{1}.spm.stats.con, con);

end
