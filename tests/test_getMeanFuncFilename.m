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

    % TODO add assert

    %     expectedFileName = 'sub-01_ses-01_task-vislocalizer_bold.nii';
    %
    %     expectedSubFuncDataDir = fullfile(fileparts(mfilename('fullpath')), ...
    %                                       'dummyData', 'derivatives', 'SPM12_CPPL', ...
    %                                       'sub-01', 'ses-01', 'func');
    %
    %     assertEqual(expectedSubFuncDataDir, subFuncDataDir);
    %     assertEqual(expectedFileName, fileName);

end
