function test_suite = test_pmCon %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_pmConBasic()
    % Small test to ensure that pmCon returns what we asked for

    addpath(genpath(fullfile(pwd, '..')));

    opt.dataDir = fullfile(pwd, 'dummyData', 'derivatives');
    opt.taskName = 'visMotion';
    opt.model.univariate.file = ...
        fullfile(pwd, 'dummyData', 'model', 'model-visMotionLoc_smdl.json');

    ffxDir = fullfile(opt.dataDir, 'SPM12_CPPL', 'sub-01', 'stats', 'ffx_visMotion', 'ffx_6');

    isMVPA = 0;

    contrasts = pmCon(ffxDir, opt.taskName, opt, isMVPA);

    assertEqual(contrasts(1).name, 'VisMot');
    assertEqual(contrasts(1).C, [1 0 0 0 0 0 0 0 0]);

    assertEqual(contrasts(2).name, 'VisStat');
    assertEqual(contrasts(2).C, [0 1 0 0 0 0 0 0 0]);

    assertEqual(contrasts(3).name, 'VisMot_gt_VisStat');
    assertEqual(contrasts(3).C, [1 -1 0 0 0 0 0 0 0]);

    assertEqual(contrasts(4).name, 'VisStat_gt_VisMot');
    assertEqual(contrasts(4).C, [-1 1 0 0 0 0 0 0 0]);

end
