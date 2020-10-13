function test_suite = test_getBoldFilenameForFFX %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_getBoldFilenameForFFXBasic()

    subID = '01';
    funcFWHM = 6;
    iSes = 1;
    iRun = 1;

    opt.taskName = 'vislocalizer';
    opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
    opt.groups = {''};
    opt.subjects = {'01'};

    [~, opt, BIDS] = getData(opt);

    [boldFileName, prefix] = getBoldFilenameForFFX(BIDS, opt, subID, funcFWHM, iSes, iRun);

    expectedFileName = fullfile(fileparts(mfilename('fullpath')), ...
                                'dummyData', 'derivatives', 'SPM12_CPPL', 'sub-01', ...
                                'ses-01', 'func', ...
                                's6wsub-01_ses-01_task-vislocalizer_bold.nii');

    assertEqual('s6w', prefix);
    assertEqual({expectedFileName}, boldFileName);

end

function test_getBoldFilenameForFFXNativeSpace()

    subID = '01';
    funcFWHM = 6;
    iSes = 1;
    iRun = 1;

    opt.taskName = 'vislocalizer';
    opt.dataDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'derivatives');
    opt.groups = {''};
    opt.subjects = {'01'};
    opt.space = 'T1w';

    [~, opt, BIDS] = getData(opt);

    [boldFileName, prefix] = getBoldFilenameForFFX(BIDS, opt, subID, funcFWHM, iSes, iRun);

    expectedFileName = fullfile(fileparts(mfilename('fullpath')), ...
                                'dummyData', 'derivatives', 'SPM12_CPPL', 'sub-01', ...
                                'ses-01', 'func', ...
                                's6rsub-01_ses-01_task-vislocalizer_bold.nii');

    assertEqual('s6r', prefix);
    assertEqual({expectedFileName}, boldFileName);

end
