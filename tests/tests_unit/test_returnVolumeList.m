function test_suite = test_returnVolumeList %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_returnVolumeList_basic()

  % GIVEN
  subLabel = '^01';
  opt = setOptions('MoAE', subLabel);

  BIDS = bids.layout(opt.dir.raw, ...
                     'use_schema', false, ...
                     'index_dependencies', false);

  boldFile = bids.query(BIDS, 'data', 'sub', '01', 'suffix', 'bold', 'extension', '.nii');

  % WHEN
  volumes = returnVolumeList(opt, boldFile{1});

  % THEN
  assertEqual(volumes, boldFile);

end

function test_returnVolumeList_maximum_volumes()

  % GIVEN
  subLabel = '^01';
  opt = setOptions('MoAE', subLabel);

  opt.glm.maxNbVols = 10;

  BIDS = bids.layout(opt.dir.raw, ...
                     'use_schema', false, ...
                     'index_dependencies', false);

  boldFile = bids.query(BIDS, 'data', 'sub', '01', 'suffix', 'bold', 'extension', '.nii');

  % WHEN
  volumes = returnVolumeList(opt, boldFile{1});

  % THEN
  assertEqual(size(volumes, 1), opt.glm.maxNbVols);

end

function test_returnVolumeList_volumes_to_select()

  % GIVEN
  subLabel = '^01';
  opt = setOptions('MoAE', subLabel);

  opt.funcVolToSelect = 1:2:70;

  BIDS = bids.layout(opt.dir.raw, ...
                     'use_schema', false, ...
                     'index_dependencies', false);

  boldFile = bids.query(BIDS, 'data', 'sub', '01', 'suffix', 'bold', 'extension', '.nii');

  % WHEN
  volumes = returnVolumeList(opt, boldFile{1});

  % THEN
  assertEqual(size(volumes, 1), numel(opt.funcVolToSelect));

end

function test_returnVolumeList_select_more_volumes_than_possible()

  % GIVEN
  subLabel = '^01';
  opt = setOptions('MoAE', subLabel);

  opt.funcVolToSelect = 1:2:500;

  BIDS = bids.layout(opt.dir.raw, ...
                     'use_schema', false, ...
                     'index_dependencies', false);

  boldFile = bids.query(BIDS, 'data', 'sub', '01', 'suffix', 'bold', 'extension', '.nii');

  % WHEN
  volumes = returnVolumeList(opt, boldFile{1});

  % THEN
  assertEqual(size(volumes, 1), 42);

end
