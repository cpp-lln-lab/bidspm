function test_pmCon()
    % Small test to ensure that pmCon returns what we asked for

    addpath(genpath(fullfile(pwd, '..')));

    opt.dataDir = fullfile(pwd, 'dummyData', 'derivatives');
    opt.taskName = 'visMotion';
    opt.model.univariate.file = fullfile(pwd, 'dummyData', 'model', 'model-visMotionLoc_smdl.json');

    ffxDir = fullfile(opt.dataDir, 'SPM12_CPPL', 'sub-01', 'stats', 'ffx_visMotion', 'ffx_6');

    isMVPA = 0;

    contrasts = pmCon(ffxDir, opt.taskName, opt, isMVPA);

    assert(isequal(contrasts(1).name, 'VisMot'));
    assert(isequal(contrasts(1).C, [1 0 0 0 0 0 0 0 0]));

    assert(isequal(contrasts(2).name, 'VisStat'));
    assert(isequal(contrasts(2).C, [0 1 0 0 0 0 0 0 0]));

    assert(isequal(contrasts(3).name, 'VisMot_gt_VisStat'));
    assert(isequal(contrasts(3).C, [1 -1 0 0 0 0 0 0 0]));

    assert(isequal(contrasts(4).name, 'VisStat_gt_VisMot'));
    assert(isequal(contrasts(4).C, [-1 1 0 0 0 0 0 0 0]));

end
