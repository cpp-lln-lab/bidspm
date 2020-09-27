function test_suite = test_getBoldFilename %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_getBoldFilenameBasic()

    subID = '01';
    funcFWHM = 6;
    iSes = 1;
    iRun = 1;

    opt.taskName = 'vislocalizer';
    opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
    opt.groups = {''};
    opt.subjects = {'01'};

    [~, opt, BIDS] = getData(opt);

    sessions = getInfo(BIDS, subID, opt, 'Sessions');

    runs = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

    [fileName, subFuncDataDir] = getBoldFilename( ...
                                                 BIDS, ...
                                                 subID, sessions{iSes}, runs{iRun}, opt);

    expectedFileName = 'sub-01_ses-01_task-vislocalizer_bold.nii';

    expectedSubFuncDataDir = fullfile(fileparts(mfilename('fullpath')), ...
                                      'dummyData', 'derivatives', 'SPM12_CPPL', ...
                                      'sub-01', 'ses-01', 'func');

    assertEqual(expectedSubFuncDataDir, subFuncDataDir);
    assertEqual(expectedFileName, fileName);

end
