function test_suite = test_createModelFamilies %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createModelFamilies_ones_dimension()

  defaultModel = BidsModel('init', true);

  outputDir = tempName();

  multiverse.motion = {'full'};
  multiverse.scrub = {true, false};

  createModelFamilies(defaultModel, multiverse, outputDir);

  files = spm_select('FPList', outputDir, '.*smdl.json');
  assertEqual(size(files, 1), 2);

end

function test_createModelFamilies_basic()

  defaultModel = BidsModel('init', true);

  outputDir = tempName();

  multiverse.motion = {'none'};
  multiverse.scrub = {false};
  multiverse.wm_csf = {'none'};
  multiverse.non_steady_state = {false};

  createModelFamilies(defaultModel, multiverse, outputDir);

  files = spm_select('FPList', outputDir, '.*smdl.json');
  assertEqual(size(files, 1), 1);

end

function test_createModelFamilies_all()

  defaultModel = BidsModel('init', true);

  outputDir = tempName();

  multiverse.motion = {'none', 'basic', 'full'};
  multiverse.scrub = {false, true};
  multiverse.wm_csf = {'none', 'basic', 'full'};
  multiverse.non_steady_state = {false, true};

  createModelFamilies(defaultModel, multiverse, outputDir);

  files = spm_select('FPList', outputDir, '.*smdl.json');
  assertEqual(size(files, 1), 3 * 2 * 3 * 2);

end
