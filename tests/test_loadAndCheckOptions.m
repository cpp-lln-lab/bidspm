function test_suite = test_loadAndCheckOptions %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_loadAndCheckOptionsBasic()

  delete('*.json');

  % create dummy json file
  jsonContent.taskName = 'vismotion';
  filename = 'options_task-vismotion.json';
  spm_jsonwrite(filename, jsonContent);

  % makes sure that it is picked up by default
  opt = loadAndCheckOptions();

  expectedOptions = defaultOptions();
  expectedOptions.taskName = 'vismotion';

  assertEqual(opt, expectedOptions);

end

function test_loadAndCheckOptionsFromFile()

  delete('*.json');

  % create dummy json file
  jsonContent.taskName = 'vismotion';
  jsonContent.space = 'individual';
  filename = 'options_task-vismotion_space-T1w.json';
  spm_jsonwrite(filename, jsonContent);

  % makes sure that it is read correctly from
  opt = loadAndCheckOptions('options_task-vismotion_space-T1w.json');

  expectedOptions = defaultOptions();
  expectedOptions.taskName = 'vismotion';
  expectedOptions.space = 'individual';

  assertEqual(opt, expectedOptions);

  delete('*.json');

end

function test_loadAndCheckOptionsFromSeveralFiles()

  delete('*.json');

  % create old dummy json file
  jsonContent.taskName = 'vismotion';
  filename = fullfile(pwd, ['options', ...
                            '_task-', jsonContent.taskName, ...
                            '_date-151501011111', ...
                            '.json']);
  spm_jsonwrite(filename, jsonContent);

  % create dummy json file with no date
  jsonContent.taskName = 'vismotion';
  jsonContent.space = 'individual';
  filename = 'options_task-vismotion_space-T1w.json';
  spm_jsonwrite(filename, jsonContent);

  % most recent option file that should be read from
  jsonContent.taskName = 'vismotion';
  jsonContent.space = 'individual';
  jsonContent.funcVoxelDims = [1 1 1];
  filename = fullfile(pwd, ['options', ...
                            '_task-', jsonContent.taskName, ...
                            '_date-' datestr(now, 'yyyymmddHHMM'), ...
                            '.json']);
  spm_jsonwrite(filename, jsonContent);

  % makes sure that the right json is read
  opt = loadAndCheckOptions();

  expectedOptions = defaultOptions();
  expectedOptions.taskName = 'vismotion';
  expectedOptions.space = 'individual';
  expectedOptions.funcVoxelDims = [1 1 1]';

  assertEqual(opt, expectedOptions);

end

function expectedOptions = defaultOptions()

  expectedOptions.sliceOrder = [];
  expectedOptions.STC_referenceSlice = [];

  expectedOptions.dataDir = '';
  expectedOptions.derivativesDir = '';

  expectedOptions.funcVoxelDims = [];

  expectedOptions.groups = {''};
  expectedOptions.subjects = {[]};

  expectedOptions.space = 'MNI';

  expectedOptions.anatReference.type = 'T1w';
  expectedOptions.anatReference.session = 1;

  expectedOptions.skullstrip.threshold = 0.75;

  expectedOptions.useFieldmaps = true;

  expectedOptions.taskName = '';

  expectedOptions.zeropad = 2;

  expectedOptions.contrastList = {};
  expectedOptions.model.file = '';

  expectedOptions.result.Steps = struct( ...
                                        'Level',  '', ...
                                        'Contrasts', struct( ...
                                                            'Name', '', ...
                                                            'Mask', false, ...
                                                            'MC', 'FWE', ...
                                                            'p', 0.05, ...
                                                            'k', 0, ...
                                                            'NIDM', true));

  expectedOptions = orderfields(expectedOptions);

end
