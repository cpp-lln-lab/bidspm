function test_suite = test_getFFXdir %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_getFFXdirBasic()

    isMVPA = false;
    funcFWFM = 0;
    subID = '01';
    opt.dataDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'raw');
    opt.taskName = 'funcLocalizer';

    expectedOutput = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'derivatives', ...
        'SPM12_CPPL', 'sub-01', 'stats', 'ffx_funcLocalizer', 'ffx_0');

    ffxDir = getFFXdir(subID, funcFWFM, opt, isMVPA);

    assertEqual(exist(expectedOutput, 'dir'), 7);

end

function test_getFFXdirMvpa()

    isMVPA = true;
    funcFWFM = 6;
    subID = '02';
    opt.dataDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'raw');
    opt.taskName = 'nBack';

    expectedOutput = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'derivatives', ...
        'SPM12_CPPL', 'sub-02', 'stats', 'ffx_nBack', 'ffx_MVPA_6');

    ffxDir = getFFXdir(subID, funcFWFM, opt, isMVPA);

    assertEqual(exist(expectedOutput, 'dir'), 7);

end
