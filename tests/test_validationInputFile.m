function test_suite = test_validationInputFile %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_validationInputFileBasic()

  directory = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'derivatives', ...
                       'cpp_spm', 'sub-01', 'ses-01', 'func');
  prefix = '';
  fileName = 'sub-01_ses-01_task-vislocalizer_bold.nii';

  expectedOutput = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'derivatives', ...
                            'cpp_spm', 'sub-01', 'ses-01', 'func', ...
                            'sub-01_ses-01_task-vislocalizer_bold.nii');

  file = validationInputFile(directory, fileName, prefix);

  assertEqual(expectedOutput, file);

end

function test_validationInputFileError()

  directory = pwd;
  prefix = 'swa';
  fileName = 'gibberish.nii.gz';

  assertExceptionThrown( ...
                        @()validationInputFile(directory, prefix, fileName), ...
                        'validationInputFile:nonExistentFile');

end
