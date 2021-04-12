% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_getMeanFuncFilename %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getMeanFuncFilenameBasic()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel);

  [BIDS, opt] = getData(opt);

  [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt);

  expectedMeanImage = 'wmeanusub-01_ses-01_task-vislocalizer_bold.nii';

  expectedmeanFuncDir = fullfile(fileparts(mfilename('fullpath')), ...
                                 'dummyData', 'derivatives', 'cpp_spm', ...
                                 'sub-01', 'ses-01', 'func');

  assertEqual(meanFuncDir, expectedmeanFuncDir);
  assertEqual(meanImage, expectedMeanImage);

end
