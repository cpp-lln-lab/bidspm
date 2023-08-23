function test_suite = test_concatenateOnsets %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_concatenateOnsets_basic()

  repetitionTime = 1;

  tempPath = tempDir();

  %% run 1
  names =     {'foo',    'bar'};
  onsets =    {[1; 10],  [3; 8]};
  durations = {[2; 2.5], [3; 0]};
  pmod = struct('name', {''}, 'param', {}, 'poly', {});
  onsetFile1 = fullfile(tempPath, 'sub-01_ses-01_task-fiz_run-1_onsets.mat');
  save(onsetFile1, ...
       'names', 'onsets', 'durations', 'pmod', ...
       '-v7');
  sess(1).multi = {onsetFile1};

  nbScans = 20;

  % only one run does nothing
  matFile = concatenateOnsets(sess, repetitionTime, nbScans);

  assertEqual(matFile, onsetFile1);

  %% run 2
  names =     {'foo',    'bar',  'alp'};
  onsets =    {[1; 10],  [3; 8], [4; 11]};
  durations = {[2; 2.5], [3; 0], [1; 2]};
  pmod = struct('name', {''}, 'param', {}, 'poly', {});
  onsetFile2 = fullfile(tempPath, 'sub-01_ses-02_task-buzz_run-1_onsets.mat');
  save(onsetFile2, ...
       'names', 'onsets', 'durations', 'pmod', ...
       '-v7');
  sess(2).multi = {onsetFile2};

  nbScans = [20 20];

  matFile = concatenateOnsets(sess, repetitionTime, nbScans);

  %
  assertEqual(exist(matFile, 'file'), 2);

  [~, filename] = fileparts(matFile);
  assertEqual(filename, 'sub-01_task-fizBuzz_onsets');

  assertEqual(exist(onsetFile1, 'file'), 0);
  assertEqual(exist(onsetFile2, 'file'), 0);

  load(matFile, 'names', 'onsets', 'durations');

  assertEqual(names,     {'alp',    'bar',          'foo'});
  assertEqual(durations, {[1; 2],   [3; 0; 3;  0],  [2; 2.5; 2;  2.5]});
  assertEqual(onsets,    {[24; 31], [3; 8; 23; 28], [1; 10;  21; 30]});

end
