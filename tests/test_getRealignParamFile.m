% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_getRealignParamFile %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getRealignParamFileBasic()

  subLabel = '01';
  session = '01';
  run = '';

  opt = setOptions('vislocalizer', subLabel);

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  [boldFileName, subFuncDataDir] = getBoldFilename(BIDS, subLabel, session, run, opt);
  realignParamFile = getRealignParamFile(fullfile(subFuncDataDir, boldFileName));

  assertEqual(realignParamFile, getExpectedFileName());

end

function test_getRealignParamFileNativeSpace()

  subLabel = '01';
  session = '01';
  run = '';

  opt = setOptions('vislocalizer', subLabel);
  opt.space = 'individual';

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  [boldFileName, subFuncDataDir] = getBoldFilename(BIDS, subLabel, session, run, opt);
  realignParamFile = getRealignParamFile(fullfile(subFuncDataDir, boldFileName));

  assertEqual(realignParamFile, getExpectedFileName());

end

function test_getRealignParamFileFFX()

  subLabel = '01';
  funcFWHM = 6;
  iSes = 1;
  iRun = 1;

  opt = setOptions('vislocalizer', subLabel);

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  [boldFileName, prefix] = getBoldFilenameForFFX(BIDS, opt, subLabel, funcFWHM, iSes, iRun);
  [subFuncDataDir, boldFileName, ext] = spm_fileparts(boldFileName);
  realignParamFile = getRealignParamFile(fullfile(subFuncDataDir, [boldFileName, ext]), prefix);

  assertEqual(realignParamFile, getExpectedFileName());

end

function  expectedFileName = getExpectedFileName()
  expectedFileName = fullfile(fileparts(mfilename('fullpath')), ...
                              'dummyData', 'derivatives', 'cpp_spm-preproc', 'sub-01', ...
                              'ses-01', 'func', ...
                              'rp_sub-01_ses-01_task-vislocalizer_bold.txt');
end
