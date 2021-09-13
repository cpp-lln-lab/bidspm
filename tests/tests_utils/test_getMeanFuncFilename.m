% (C) Copyright 2020 CPP_SPM developers

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

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt);

  expectedMeanImage = 'sub-01_ses-01_task-vislocalizer_space-individual_desc-mean_bold.nii';

  expectedmeanFuncDir = fullfile(getDummyDataDir('preproc'), ...
                                 'sub-01', 'ses-01', 'func');

  assertEqual(meanFuncDir, expectedmeanFuncDir);
  assertEqual(meanImage, expectedMeanImage);

  opt.query.space = 'MNI';
  meanImage = getMeanFuncFilename(BIDS, subLabel, opt);

  expectedMeanImage = 'sub-01_ses-01_task-vislocalizer_space-IXI549Spacel_desc-mean_bold.nii';

end
