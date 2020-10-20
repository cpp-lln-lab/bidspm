function test_suite = test_createAndReturnOnsetFile %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_createAndReturnOnsetFileBasic()

    isMVPA = false;
    subID = '01';
    funcFWHM = 6;
    iSes = 1;
    iRun = 1;

    opt.taskName = 'vislocalizer';
    opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
    opt.subjects = {'01'};
    opt.model.univariate.file = fullfile(fileparts(mfilename('fullpath')), ...
                                         'dummyData', 'models', ...
                                         'model-vislocalizer_smdl.json');

    opt = checkOptions(opt);                                 
                                
    [~, opt, BIDS] = getData(opt);

    boldFileName = getBoldFilenameForFFX(BIDS, opt, subID, funcFWHM, iSes, iRun);

    onsetFileName = createAndReturnOnsetFile(opt, subID, funcFWHM, boldFileName, isMVPA);

    expectedFileName = fullfile(fileparts(mfilename('fullpath')), ...
                                'dummyData', 'derivatives', 'SPM12_CPPL', 'sub-01', 'stats', ...
                                'ffx_task-vislocalizer', 'ffx_FWHM-6', ...
                                'onsets_sub-01_ses-01_task-vislocalizer_events.mat');

    assertEqual(exist(onsetFileName, 'file'), 2);
    assertEqual(exist(expectedFileName, 'file'), 2);

end
