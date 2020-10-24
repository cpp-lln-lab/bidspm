function test_suite = test_createDataDictionary %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_createDataDictionaryBasic()

    subID = '01';
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

    createDataDictionary(subFuncDataDir, fileName, 3);

    expectedFileName = fullfile( ...
                                subFuncDataDir, ...
                                'sub-01_ses-01_task-vislocalizer_desc-confounds_regressors.json');

    content = spm_jsonread(expectedFileName);

    expectedNbColumns = 27;
    expectedHeaderCol = 'censoring_regressor_3';

    assertEqual(numel(content.Columns), expectedNbColumns);
    assertEqual(content.Columns{expectedNbColumns}, 'censoring_regressor_3');

end
