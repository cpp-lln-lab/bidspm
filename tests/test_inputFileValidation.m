function test_suite = test_inputFileValidation %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_inputFileValidationBasic()

    directory = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'derivatives', ...
                         'SPM12_CPPL', 'sub-01', 'ses-01', 'func');
    prefix = '';
    fileName = 'sub-01_ses-01_task-vislocalizer_bold.nii';

    expectedOutput = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'derivatives', ...
                              'SPM12_CPPL', 'sub-01', 'ses-01', 'func', ...
                              'sub-01_ses-01_task-vislocalizer_bold.nii');

    file = inputFileValidation(directory, fileName, prefix);

    assertEqual(expectedOutput, file{1});

end

function test_inputFileValidationError()

    directory = pwd;
    prefix = 'swa';
    fileName = 'gibberish.nii.gz';

    assertExceptionThrown( ...
                          @()inputFileValidation(directory, prefix, fileName), ...
                          'inputFileValidation:nonExistentFile');

end
