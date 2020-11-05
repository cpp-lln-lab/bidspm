function test_suite = test_getRealignParamFile %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getRealignParamFileBasic()

  subID = '01';
  session = '01';
  run = '';

  opt.taskName = 'vislocalizer';
  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.subjects = {subID};

  opt = checkOptions(opt);

  [~, opt, BIDS] = getData(opt);

  [boldFileName, subFuncDataDir] = getBoldFilename(BIDS, subID, session, run, opt);
  realignParamFile = getRealignParamFile(fullfile(subFuncDataDir, boldFileName));

  expectedFileName = fullfile(fileparts(mfilename('fullpath')), ...
                              'dummyData', 'derivatives', 'SPM12_CPPL', 'sub-01', ...
                              'ses-01', 'func', ...
                              'rp_sub-01_ses-01_task-vislocalizer_bold.txt');

  assertEqual(expectedFileName, realignParamFile);

end

function test_getRealignParamFileNativeSpace()

  subID = '01';
  session = '01';
  run = '';

  opt.taskName = 'vislocalizer';
  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.subjects = {subID};
  opt.space = 'individual';

  opt = checkOptions(opt);

  [~, opt, BIDS] = getData(opt);

  [boldFileName, subFuncDataDir] = getBoldFilename(BIDS, subID, session, run, opt);
  realignParamFile = getRealignParamFile(fullfile(subFuncDataDir, boldFileName));

  expectedFileName = fullfile(fileparts(mfilename('fullpath')), ...
                              'dummyData', 'derivatives', 'SPM12_CPPL', 'sub-01', ...
                              'ses-01', 'func', ...
                              'rp_sub-01_ses-01_task-vislocalizer_bold.txt');

  assertEqual(expectedFileName, realignParamFile);

end

function test_getRealignParamFileFFX()

  subID = '01';
  funcFWHM = 6;
  iSes = 1;
  iRun = 1;

  opt.taskName = 'vislocalizer';
  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.subjects = {subID};
  opt.space = 'MNI';

  opt = checkOptions(opt);

  [~, opt, BIDS] = getData(opt);

  [boldFileName, prefix] = getBoldFilenameForFFX(BIDS, opt, subID, funcFWHM, iSes, iRun);
  [subFuncDataDir, boldFileName, ext] = spm_fileparts(boldFileName);
  realignParamFile = getRealignParamFile(fullfile(subFuncDataDir, [boldFileName, ext]), prefix);

  expectedFileName = fullfile(fileparts(mfilename('fullpath')), ...
                              'dummyData', 'derivatives', 'SPM12_CPPL', 'sub-01', ...
                              'ses-01', 'func', ...
                              'rp_sub-01_ses-01_task-vislocalizer_bold.txt');

  assertEqual(expectedFileName, realignParamFile);

end
