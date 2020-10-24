function test_suite = test_getMeanFuncFilename %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_getMeanFuncFilenameBasic()

    subID = '01';

    opt.taskName = 'vislocalizer';
    opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
    opt.groups = {''};
    opt.subjects = {subID};

    opt = checkOptions(opt);

    [~, opt, BIDS] = getData(opt);

    [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subID, opt);

    expectedMeanImage = 'meanusub-01_ses-01_task-vislocalizer_bold.nii';

    expectedmeanFuncDir = fullfile(fileparts(mfilename('fullpath')), ...
                                   'dummyData', 'derivatives', 'SPM12_CPPL', ...
                                   'sub-01', 'ses-01', 'func');

    assertEqual(meanFuncDir, expectedmeanFuncDir);
    assertEqual(meanImage, expectedMeanImage);

end
