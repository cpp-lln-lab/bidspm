% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchSaveCoregistrationMatrix %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSaveCoregistrationMatrix_basic()

  % necessarry to deal with SPM module dependencies
  spm_jobman('initcfg');

  subLabel = '^01';

  opt = setOptions('vismotion', subLabel);
  opt.query = struct('acq', '');

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  opt.orderBatches.coregister = 1;

  matlabbatch = {};
  matlabbatch = setBatchSaveCoregistrationMatrix(matlabbatch, BIDS, opt, subLabel);

  expectedBatch = returnExpectedBatch();
  assertEqual(matlabbatch{1}.cfg_basicio.var_ops.cfg_save_vars, ...
              expectedBatch{1}.cfg_basicio.var_ops.cfg_save_vars);

end

function expectedBatch = returnExpectedBatch()

  expectedBatch = {};

  subFuncDataDir = fullfile(getDummyDataDir('preproc'), 'sub-01', 'ses-01', 'func');

  fileName = 'sub-01_ses-01_task-vismotion_from-scanner_to-T1w_mode-image_xfm.mat';

  expectedBatch{end + 1}.cfg_basicio.var_ops.cfg_save_vars.name = fileName;
  expectedBatch{end}.cfg_basicio.var_ops.cfg_save_vars.outdir = {subFuncDataDir};
  expectedBatch{end}.cfg_basicio.var_ops.cfg_save_vars.vars.vname = 'transformationMatrix';

  expectedBatch{end}.cfg_basicio.var_ops.cfg_save_vars.vars.vcont(1) = ...
      cfg_dep( ...
              'Coregister: Estimate: Coregistration Matrix', ...
              substruct( ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}), ...
              substruct('.', 'M'));

  expectedBatch{end}.cfg_basicio.var_ops.cfg_save_vars.saveasstruct = false;

end
