% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchSubjectLevelContrasts %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
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

  consess{1}.tcon.name = 'VisMot_1'; %#ok<*AGROW>
  consess{end}.tcon.convec = [1 0 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  consess{end + 1}.tcon.name = 'VisStat_1'; %#ok<*AGROW>
  consess{end}.tcon.convec = [0 1 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  consess{end + 1}.tcon.name = 'VisMot_gt_VisStat_1'; %#ok<*AGROW>
  consess{end}.tcon.convec = [1 -1 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  consess{end + 1}.tcon.name = 'VisStat_gt_VisMot_1'; %#ok<*AGROW>
  consess{end}.tcon.convec = [-1 1 0 0 0 0 0 0 0];
  consess{end}.tcon.sessrep = 'none';

  con.consess = consess;

  assertEqual(matlabbatch{1}.spm.stats.con, con);

end
