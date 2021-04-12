% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_loadAndCheckOptions %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_loadAndCheckOptionsBasic()

  mkdir cfg;
  delete(fullfile(pwd, 'cfg', '*.json'));

  % create dummy json file
  jsonContent.taskName = 'vismotion';
  filename = fullfile(pwd, 'cfg', 'options_task-vismotion.json');
  spm_jsonwrite(filename, jsonContent);

  % makes sure that it is picked up by default
  opt = loadAndCheckOptions();

  expectedOptions = defaultOptions('vismotion');

  assertEqual(opt, expectedOptions);

end

function test_loadAndCheckOptionsStructure()

  mkdir cfg;
  delete(fullfile(pwd, 'cfg', '*.json'));

  % create dummy json file
  opt.taskName = 'vismotion';

  % makes sure that it is picked up by default
  opt = loadAndCheckOptions(opt);

  expectedOptions = defaultOptions('vismotion');

  assertEqual(opt, expectedOptions);

end

function test_loadAndCheckOptionsFromFile()

  mkdir cfg;
  delete(fullfile(pwd, 'cfg', '*.json'));

  % create dummy json file
  jsonContent.taskName = 'vismotion';
  jsonContent.space = 'individual';
  jsonContent.groups = {''};
  jsonContent.subjects = {[]};

  filename = fullfile(pwd, 'cfg', 'options_task-vismotion_space-T1w.json');
  spm_jsonwrite(filename, jsonContent);

  % makes sure that it is read correctly from
  opt = loadAndCheckOptions(filename);

  expectedOptions = defaultOptions('vismotion');
  expectedOptions.space = 'individual';

  assertEqual(opt, expectedOptions);

  delete('*.json');

end

function test_loadAndCheckOptionsFromSeveralFiles()

  mkdir cfg;
  delete(fullfile(pwd, 'cfg', '*.json'));

  % create old dummy json file
  jsonContent.taskName = 'vismotion';
  filename = fullfile(pwd, 'cfg', ['options', ...
                                   '_task-', jsonContent.taskName, ...
                                   '_date-151501011111', ...
                                   '.json']);
  spm_jsonwrite(filename, jsonContent);

  % create dummy json file with no date
  jsonContent.taskName = 'vismotion';
  jsonContent.space = 'individual';
  filename = fullfile(pwd, 'cfg', 'options_task-vismotion_space-T1w.json');
  spm_jsonwrite(filename, jsonContent);

  % most recent option file that should be read from
  jsonContent.taskName = 'vismotion';
  jsonContent.space = 'individual';
  jsonContent.funcVoxelDims = [1 1 1];
  filename = fullfile(pwd, 'cfg', ['options', ...
                                   '_task-', jsonContent.taskName, ...
                                   '_date-' datestr(now, 'yyyymmddHHMM'), ...
                                   '.json']);
  spm_jsonwrite(filename, jsonContent);

  % makes sure that the right json is read
  opt = loadAndCheckOptions();

  expectedOptions = defaultOptions('vismotion');
  expectedOptions.space = 'individual';
  expectedOptions.funcVoxelDims = [1 1 1]';

  assertEqual(opt, expectedOptions);

end

function test_loadAndCheckOptionsMoAE()

  WD = fullfile('..', 'demos', 'MoAE/');

  optionsFilesList = { ...
                      'options_task-auditory.json'; ...
                      'options_task-auditory_unwarp-0.json'; ...
                      'options_task-auditory_unwarp-0_space-individual.json'; ...
                      'options_task-auditory_space-individual.json'};

  for iOption = 1:size(optionsFilesList, 1)

    fprintf(1, repmat('\n', 1, 5));

    optionJsonFile = fullfile(WD, 'options', optionsFilesList{iOption});
    opt = loadAndCheckOptions(optionJsonFile);
  end

end
