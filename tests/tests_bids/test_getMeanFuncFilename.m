% (C) Copyright 2020 bidspm developers

function test_suite = test_getMeanFuncFilename %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getMeanFuncFilename_basic()

  subLabel = '^01';

  opt = setOptions('vislocalizer', subLabel);

  BIDS = getLayout(opt);

  [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt);

  expectedMeanImage = 'sub-01_ses-01_task-vislocalizer_space-individual_desc-mean_bold.nii';

  expectedmeanFuncDir = fullfile(getDummyDataDir('preproc'), ...
                                 'sub-01', 'ses-01', 'func');

  assertEqual(meanFuncDir, expectedmeanFuncDir);
  assertEqual(meanImage, expectedMeanImage);

  opt.query.space = 'IXI549Space';
  meanImage = getMeanFuncFilename(BIDS, subLabel, opt);

  expectedMeanImage = 'sub-01_ses-01_task-vislocalizer_space-IXI549Space_desc-mean_bold.nii';

end
