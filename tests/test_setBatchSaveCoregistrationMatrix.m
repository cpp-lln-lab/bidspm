function test_suite = test_setBatchSaveCoregistrationMatrix %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setBatchSaveCoregistrationMatrixBasic()

    % necessarry to deal with SPM module dependencies
    spm_jobman('initcfg');

    opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
    opt.taskName = 'vismotion';

    opt = checkOptions(opt);

    [~, opt, BIDS] = getData(opt);
    subID = '02';

    opt.orderBatches.coregister = 1;

    matlabbatch = {};
    matlabbatch = setBatchSaveCoregistrationMatrix(matlabbatch, BIDS, subID, opt);

    expectedBatch = returnExpectedBatch();
    assertEqual(matlabbatch, expectedBatch);

end

function expectedBatch = returnExpectedBatch()

    expectedBatch = {};

    subFuncDataDir = fullfile(fileparts( ...
                                        mfilename('fullpath')), ...
                              'dummyData', ...
                              'derivatives', ...
                              'SPM12_CPPL', ...
                              'sub-02', ...
                              'ses-01', ...
                              'func');

    fileName = 'sub-02_ses-01_task-vismotion_run-1_from-scanner_to-T1w_mode-image_xfm.mat';

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
