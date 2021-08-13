% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_getRealignParamFilename %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getRealignParamFilenameBasic()

  subLabel = '01';
  session = '01';
  run = '';

  opt = setOptions('vislocalizer', subLabel);

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  realignParamFile = getRealignParamFilename(BIDS, subLabel, session, run, opt);

  assertEqual(realignParamFile, getExpectedFileName());

end

function  expectedFileName = getExpectedFileName()
  expectedFileName = fullfile(fileparts(mfilename('fullpath')), ...
                              'dummyData', 'derivatives', 'cpp_spm-preproc', 'sub-01', ...
                              'ses-01', 'func', ...
                              'rp_sub-01_ses-01_task-vislocalizer_bold.txt');
end
