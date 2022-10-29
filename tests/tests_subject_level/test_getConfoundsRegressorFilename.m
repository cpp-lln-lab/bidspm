% (C) Copyright 2020 bidspm developers

function test_suite = test_getConfoundsRegressorFilename %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getConfoundRegressorFile_basic()

  subLabel = '^01';
  session = '01';
  run = '';

  opt = setOptions('vislocalizer', subLabel);

  BIDS = getLayout(opt);

  opt.query.task = 'vislocalizer';

  realignParamFile = getConfoundsRegressorFilename(BIDS, opt, subLabel, session, run);

  assertEqual(realignParamFile, getExpectedFilename());

end

function  expectedFilename = getExpectedFilename()
  funcDir = fullfile(getDummyDataDir('preproc'), 'sub-01', 'ses-01', 'func');
  expectedFilename =  {fullfile(funcDir, ...
                                'sub-01_ses-01_task-vislocalizer_desc-confounds_regressors.tsv')};

end
