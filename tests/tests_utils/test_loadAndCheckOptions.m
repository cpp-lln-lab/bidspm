function test_suite = test_loadAndCheckOptions %#ok<*STOUT>
  % (C) Copyright 2020 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_loadAndCheckOptions_basic()

  PWD = setUp();

  % create dummy json file
  jsonContent.taskName = 'vismotion';
  jsonContent.verbosity = 0;
  filename = fullfile(pwd, 'cfg', 'options_task-vismotion.json');
  spm_jsonwrite(filename, jsonContent);

  % makes sure that it is picked up by default
  opt = loadAndCheckOptions();

  expectedOptions = defaultOptions('vismotion');
  expectedOptions.verbosity = 0;
  assertEqual(opt, expectedOptions);

  teardown(PWD);
end

function test_loadAndCheckOptions_structure()

  PWD = setUp();

  % create dummy json file
  opt = setTestCfg();
  opt.taskName = 'vismotion';

  opt = loadAndCheckOptions(opt);

  expectedOptions = defaultOptions('vismotion');
  expectedOptions.verbosity = 0;
  expectedOptions.dryRun = 1;

  assertEqual(opt, expectedOptions);

  teardown(PWD);
end

function test_loadAndCheckOptions_from_file()

  PWD = setUp();

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

  teardown(PWD);
end

function test_loadAndCheckOptions_from_several_files()

  PWD = setUp();

  % create old dummy json file
  jsonContent.taskName = 'vismotion';
  filename = fullfile(pwd, 'cfg', ['1515-01-01T11-11_options', ...
                                   '_task-', jsonContent.taskName, ...
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
  filename = fullfile(pwd, 'cfg', [timeStamp(), '_options', ...
                                   '_task-', jsonContent.taskName, ...
                                   '.json']);
  spm_jsonwrite(filename, jsonContent);

  % makes sure that the right json is read
  opt = loadAndCheckOptions();

  expectedOptions = defaultOptions('vismotion');
  expectedOptions.space = {'individual'};
  expectedOptions.funcVoxelDims = [1 1 1]';
  expectedOptions.verbosity = 0;

  assertEqual(opt, expectedOptions);

  teardown(PWD);
end

function test_loadAndCheckOptions_moae()

  PWD = setUp();

  jsonContent = setOptions('MoAE');
  jsonContent.verbosity = 0;

  optionJsonFile = fullfile(pwd, 'cfg', 'options_task-auditory.json');
  spm_jsonwrite(optionJsonFile, jsonContent);

  opt = loadAndCheckOptions(optionJsonFile);

  teardown(PWD);

end

function PWD = setUp()
  PWD = pwd;
  tmpDir = tempName();
  cd(tmpDir);
  spm_mkdir cfg;
end

function teardown(pth)
  cd(pth);
end

function opt = setTestCfg()
  opt.verbosity = 0;
  opt.dryRun = true;
end
