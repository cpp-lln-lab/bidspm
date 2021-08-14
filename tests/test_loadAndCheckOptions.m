% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_loadAndCheckOptions %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_loadAndCheckOptionsBasic()

  setUp();

  % create dummy json file
  jsonContent.taskName = 'vismotion';
  filename = fullfile(pwd, 'cfg', 'options_task-vismotion.json');
  spm_jsonwrite(filename, jsonContent);

  % makes sure that it is picked up by default
  opt = loadAndCheckOptions();

  expectedOptions = defaultOptions('vismotion');

  assertEqual(opt, expectedOptions);

  cleanUp();

end

function test_loadAndCheckOptionsStructure()

  setUp();

  % create dummy json file
  opt = setTestCfg();
  opt.taskName = 'vismotion';

  opt = loadAndCheckOptions(opt);

  expectedOptions = defaultOptions('vismotion');
  expectedOptions.verbosity = 0;
  expectedOptions.dryRun = 1;

  assertEqual(opt, expectedOptions);

  cleanUp();

end

function test_loadAndCheckOptionsFromFile()

  setUp();

  % create dummy json file
  jsonContent.taskName = 'vismotion';
  jsonContent.space = {'individual'};
  jsonContent.verbosity = 0;
  jsonContent.groups = {''};
  jsonContent.subjects = {[]};

  filename = fullfile(pwd, 'cfg', 'options_task-vismotion_space-T1w.json');
  spm_jsonwrite(filename, jsonContent);

  % makes sure that it is read correctly from
  opt = loadAndCheckOptions(filename);

  expectedOptions = defaultOptions('vismotion');
  expectedOptions.space = {'individual'};
  expectedOptions.verbosity = 0;

  assertEqual(opt, expectedOptions);

  cleanUp();

end

function test_loadAndCheckOptionsFromSeveralFiles()

  setUp();

  % create old dummy json file
  jsonContent.taskName = 'vismotion';
  filename = fullfile(pwd, 'cfg', ['options', ...
                                   '_task-', jsonContent.taskName, ...
                                   '_date-151501011111', ...
                                   '.json']);
  spm_jsonwrite(filename, jsonContent);

  % create dummy json file with no date
  jsonContent.taskName = 'vismotion';
  jsonContent.space = {'individual'};
  filename = fullfile(pwd, 'cfg', 'options_task-vismotion_space-T1w.json');
  spm_jsonwrite(filename, jsonContent);

  % most recent option file that should be read from
  jsonContent.taskName = 'vismotion';
  jsonContent.space = {'individual'};
  jsonContent.verbosity = 0;
  jsonContent.funcVoxelDims = [1 1 1];
  filename = fullfile(pwd, 'cfg', ['options', ...
                                   '_task-', jsonContent.taskName, ...
                                   '_date-' datestr(now, 'yyyymmddHHMM'), ...
                                   '.json']);
  spm_jsonwrite(filename, jsonContent);

  % makes sure that the right json is read
  opt = loadAndCheckOptions();

  expectedOptions = defaultOptions('vismotion');
  expectedOptions.space = {'individual'};
  expectedOptions.funcVoxelDims = [1 1 1]';
  expectedOptions.verbosity = 0;

  assertEqual(opt, expectedOptions);

  cleanUp();

end

function test_loadAndCheckOptionsMoAE()

  setUp();

  jsonContent = setOptions('MoAE');

  optionJsonFile = fullfile(pwd, 'cfg', 'options_task-auditory.json');
  spm_jsonwrite(optionJsonFile, jsonContent);

  opt = loadAndCheckOptions(optionJsonFile);

  cleanUp();

end

function setUp
  spm_mkdir cfg;
  delete(fullfile(pwd, 'cfg', '*.json'));
end

function cleanUp()

  pause(1);

  if isOctave()
    confirm_recursive_rmdir (true, 'local');
  end
  rmdir(fullfile(pwd, 'cfg'), 's');

  delete('*.json');

end

function opt = setTestCfg()

  opt.verbosity = 0;
  opt.dryRun = true;

end
