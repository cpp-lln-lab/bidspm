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
  opt = checkOptions(opt);

  [BIDS, opt] = getData(opt);

  [boldFileName, subFuncDataDir] = getBoldFilename(BIDS, subLabel, session, run, opt);
  realignParamFile = getRealignParamFile(fullfile(subFuncDataDir, boldFileName));

  expectedFileName = fullfile(fileparts(mfilename('fullpath')), ...
                              'dummyData', 'derivatives', 'cpp_spm', 'sub-01', ...
                              'ses-01', 'func', ...
                              'rp_sub-01_ses-01_task-vislocalizer_bold.txt');

  assertEqual(expectedFileName, realignParamFile);

end

function test_getRealignParamFileNativeSpace()

  subLabel = '01';
  session = '01';
  run = '';

  opt = setOptions('vislocalizer', subLabel);
  opt.space = 'individual';
  opt = checkOptions(opt);

  [BIDS, opt] = getData(opt);

  [boldFileName, subFuncDataDir] = getBoldFilename(BIDS, subLabel, session, run, opt);
  realignParamFile = getRealignParamFile(fullfile(subFuncDataDir, boldFileName));

  expectedFileName = fullfile(fileparts(mfilename('fullpath')), ...
                              'dummyData', 'derivatives', 'cpp_spm', 'sub-01', ...
                              'ses-01', 'func', ...
                              'rp_sub-01_ses-01_task-vislocalizer_bold.txt');

  assertEqual(expectedFileName, realignParamFile);

end

function test_getRealignParamFileFFX()

  subLabel = '01';
  funcFWHM = 6;
  iSes = 1;
  iRun = 1;

  opt = setOptions('vislocalizer', subLabel);
  opt = checkOptions(opt);

  [BIDS, opt] = getData(opt);

  [boldFileName, prefix] = getBoldFilenameForFFX(BIDS, opt, subLabel, funcFWHM, iSes, iRun);
  [subFuncDataDir, boldFileName, ext] = spm_fileparts(boldFileName);
  realignParamFile = getRealignParamFile(fullfile(subFuncDataDir, [boldFileName, ext]), prefix);

  expectedFileName = fullfile(fileparts(mfilename('fullpath')), ...
                              'dummyData', 'derivatives', 'cpp_spm', 'sub-01', ...
                              'ses-01', 'func', ...
                              'rp_sub-01_ses-01_task-vislocalizer_bold.txt');

  assertEqual(expectedFileName, realignParamFile);

end
