function test_suite = test_getRFXdir %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_getRFXdirBasic()

    funcFWHM = 0;
    conFWHM = 0;

    opt.dataDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'raw');
    opt.taskName = 'funcLocalizer';
    contrastName = 'stim_gt_baseline';

    rfxDir = getRFXdir(opt, funcFWHM, conFWHM, contrastName);

    expectedOutput = fullfile( ...
        fileparts(mfilename('fullpath')), ...
        'dummyData', ...
        'derivatives', ...
        'SPM12_CPPL', ...
        'group', ...
        'rfx_task-funcLocalizer', ...
        'rfx_funcFWHM-0_conFWHM-0', ...
        'stim_gt_baseline');

    assertEqual(exist(expectedOutput, 'dir'), 7);

end
