function test_suite = test_addConfoundsToDesignMatrix %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_addConfoundsToDesignMatrix_from_file()

  modelFile = fullfile(getTestDataDir(), 'models', ...
                       'model-balloonanalogrisktask_smdl.json');

  strategy.strategies = {'motion', 'non_steady_state'};
  strategy.motion = 'basic';
  strategy.non_steady_state = true;

  bm = addConfoundsToDesignMatrix(modelFile, 'strategy', strategy);

  assertEqual(numel(bm.Nodes{1}.Model.X), 3);
  assertEqual(ismember({'rot_?', 'trans_?', 'non_steady_state_outlier*'}, ...
                       bm.Nodes{1}.Model.X), ...
              true(1, 3));

end

function test_addConfoundsToDesignMatrix_with_numerial_and_no_duplicate()

  bm = BidsModel('init', true);
  bm.Nodes{1}.Model.X = {1, 'rot_?'};

  strategy.strategies = {'motion'};
  strategy.motion = 'basic';
  bm = addConfoundsToDesignMatrix(bm, 'strategy', strategy);

  assertEqual(numel(bm.Nodes{1}.Model.X), 3);

  numeric = cellfun(@(x) isnumeric(x), bm.Nodes{1}.Model.X);
  assertEqual(ismember({'rot_?', 'trans_?'}, ...
                       bm.Nodes{1}.Model.X(~numeric)), ...
              true(1, 2));

end

function test_addConfoundsToDesignMatrix_full()

  bm = BidsModel('init', true);

  strategy.strategies = {'motion', 'wm_csf', 'scrub', 'non_steady_state'};
  strategy.motion = 'full';
  strategy.scrub = true;
  strategy.wm_csf = 'full';
  strategy.non_steady_state = true;

  bm = addConfoundsToDesignMatrix(bm, 'strategy', strategy);

  assertEqual(numel(bm.Nodes{1}.Model.X), 6);

  assertEqual(ismember({'rot_*', 'trans_*', ...
                        'csf_*',    'white_*', ...
                        'motion_outlier*', 'non_steady_state_outlier*'}, ...
                       bm.Nodes{1}.Model.X), ...
              true(1, 6));
end

function test_addConfoundsToDesignMatrix_update_name()

  bm = BidsModel('init', true);

  nameBefore = bm.Nodes{1}.Name;

  strategy.strategies = {'motion', 'wm_csf', 'scrub', 'non_steady_state'};
  strategy.motion = 'full';
  strategy.scrub = true;
  strategy.wm_csf = 'full';
  strategy.non_steady_state = true;

  bm = addConfoundsToDesignMatrix(bm, 'strategy', strategy);
  assertEqual(bm.Nodes{1}.Name, nameBefore);

  bm = addConfoundsToDesignMatrix(bm, 'strategy', strategy, 'updateName', true);
  assertEqual(bm.Nodes{1}.Name, [nameBefore '_rp-full_scrub-1_tissue-full_nsso-1']);
end

function test_addConfoundsToDesignMatrix_default()

  bm = BidsModel('init', true);

  bm = addConfoundsToDesignMatrix(bm);
  assertEqual(numel(bm.Nodes{1}.Model.X), 0);

  strategy.strategies = {'motion', 'non_steady_state'};
  strategy.motion = 'basic';
  strategy.non_steady_state = true;

  bm = addConfoundsToDesignMatrix(bm, 'strategy', strategy);
  assertEqual(numel(bm.Nodes{1}.Model.X), 3);
  assertEqual(ismember({'rot_?', 'trans_?', 'non_steady_state_outlier*'}, ...
                       bm.Nodes{1}.Model.X), ...
              true(1, 3));

end

function test_addConfoundsToDesignMatrix_warning()

  if bids.internal.is_octave()
    moxunit_throw_test_skipped_exception('testing warning with octave');
  end

  bm = BidsModel('init', true);

  strategy.strategies = {'foo'};

  assertWarning(@()addConfoundsToDesignMatrix(bm, 'strategy', strategy), ...
                'addConfoundsToDesignMatrix:unknownStrategy');

  strategy.strategies = {'global_signal'};

  assertWarning(@()addConfoundsToDesignMatrix(bm, 'strategy', strategy), ...
                'addConfoundsToDesignMatrix:notImplemented');
end
