function test_suite = test_getGrpLevelContrastToCompute %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_getGrpLevelContrastToComputeBasic()

    isMVPA = false;
    opt.model.univariate.file = fullfile(fileparts(mfilename('fullpath')), ...
        'dummyData', 'model', 'model-visMotionLoc_smdl.json');

    [grpLvlCon, iStep] = getGrpLevelContrastToCompute(opt, isMVPA);

    AutoContrasts = {
        'trial_type.VisMot'; ...
        'trial_type.VisStat'; ...
        'VisMot_gt_VisStat'; ...
        'VisStat_gt_VisMot'};

    assertEqual(iStep, 2);
    assertEqual(grpLvlCon, AutoContrasts);

    %%
    isMVPA = true;
    opt.model.multivariate.file = fullfile(fileparts(mfilename('fullpath')), ...
        'dummyData', 'model', 'model-vislocalizer_smdl.json');

    [grpLvlCon, iStep] = getGrpLevelContrastToCompute(opt, isMVPA);

    AutoContrasts = {
        'trial_type.VisMot'; ...
        'trial_type.VisStat'; ...
        'VisMot_gt_VisStat'; ...
        'VisStat_gt_VisMot'};

    assertEqual(iStep, 3);
    assertEqual(grpLvlCon, AutoContrasts);

end
