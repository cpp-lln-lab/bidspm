% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchSTC %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSTC_dual_task()

  subLabel = '^01';
  useRaw = true;
  opt = setOptions({'vismotion', 'rest'}, subLabel, useRaw);

  opt.query.acq = '';

  BIDS = bids.layout(opt.dir.preproc);
  matlabbatch = {};
  setBatchSTC(matlabbatch, BIDS, opt, subLabel);

end

function test_setBatchSTC_error_dfferent_repetition_time()

  subLabel = '^01';
  useRaw = true;
  opt = setOptions({'vismotion', 'vislocalizer'}, subLabel, useRaw);

  opt.query.acq = '';

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  matlabbatch = {};
  assertExceptionThrown( ...
                        @()setBatchSTC(matlabbatch, BIDS, opt, subLabel), ...
                        'getAndCheckRepetitionTime:differentRepetitionTime');

end

function test_setBatchSTC_skip()

  subLabel = '^01';
  useRaw = true;
  opt = setOptions('vismotion', subLabel, useRaw);

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  opt.stc.skip = true;

  matlabbatch = {};
  matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);
  assertEqual(matlabbatch, {});

end

function test_setBatchSTC_empty()

  subLabel = '^01';
  useRaw = true;
  opt = setOptions('vislocalizer', subLabel, useRaw);

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  matlabbatch = {};
  matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);

  % no slice timing info for this run so nothing should be returned.
  assertEqual(matlabbatch, {});

end

function test_setBatchSTC_force()

  subLabel = '^01';
  useRaw = true;
  opt = setOptions('vislocalizer', subLabel, useRaw);

  % we give it some slice timing value to force slice timing to happen
  opt.stc.sliceOrder = linspace(0, 1.6, 10);
  opt.stc.sliceOrder(end - 1:end) = [];
  opt.stc.referenceSlice = 1.6 / 2;

  opt = checkOptions(opt);

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  matlabbatch = {};
  matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);

  TR = 1.55;
  expectedBatch = returnExpectedBatch(opt.stc.sliceOrder, opt.stc.referenceSlice, TR);

  runCounter = 1;
  for iSes = 1:2
    fileName = bids.query(BIDS, 'data', ...
                          'sub', subLabel, ...
                          'ses', sprintf('0%i', iSes), ...
                          'task', opt.taskName, ...
                          'suffix', 'bold', ...
                          'extension', '.nii', ...
                          'prefix', '',  ...
                          'space', '', 'desc', '');
    expectedBatch{1}.spm.temporal.st.scans{runCounter} = {fileName{1}};
    runCounter = runCounter + 1;
  end

  assertEqual(matlabbatch{1}.spm.temporal.st, expectedBatch{1}.spm.temporal.st);

end

function test_setBatchSTC_basic()

  subLabel = '^01';
  useRaw = true;
  opt = setOptions('vismotion', subLabel, useRaw);

  opt.query = struct('acq', '');

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  matlabbatch = {};
  matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);

  TR = 1.5;
  sliceOrder = repmat([ ...
                       0.5475, 0, 0.3825, 0.055, 0.4375, 0.11, 0.4925, 0.22, 0.6025, ...
                       0.275, 0.6575, ...
                       0.3275, 0.71, 0.165], 1, 3)';
  referenceSlice = 0.355;

  expectedBatch = returnExpectedBatch(sliceOrder, referenceSlice, TR);

  runCounter = 1;
  for iSes = 1:2
    fileName = bids.query(BIDS, 'data', ...
                          'sub', subLabel, ...
                          'ses', sprintf('0%i', iSes), ...
                          'task', opt.taskName, ...
                          'suffix', 'bold', ...
                          'extension', '.nii', ...
                          'prefix', '',  ...
                          'acq', '', ...
                          'space', '', 'desc', '');
    expectedBatch{1}.spm.temporal.st.scans{runCounter} = ...
      {fileName{1}};
    expectedBatch{1}.spm.temporal.st.scans{runCounter + 1} = ...
      {fileName{2}};
    runCounter = runCounter + 2;
  end

  assertEqual(matlabbatch{1}.spm.temporal.st, expectedBatch{1}.spm.temporal.st);

end

function test_setBatchSTC_error_invalid_input_time()

  subLabel = '01';
  useRaw = true;
  opt = setOptions('vislocalizer', subLabel, useRaw);

  opt.stc.sliceOrder = linspace(0, 1.6, 10);
  opt.stc.sliceOrder(end) = [];
  opt.stc.referenceSlice = 2; % impossible reference value

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  matlabbatch = {};
  assertExceptionThrown( ...
                        @()setBatchSTC(matlabbatch, BIDS, opt, subLabel), ...
                        'setBatchSTC:invalidInputTime');

end

function expectedBatch = returnExpectedBatch(sliceOrder, referenceSlice, TR)

  nbSlices = length(sliceOrder);
  TA = TR - (TR / nbSlices);
  TA = ceil(TA * 1000) / 1000;

  temporal.st.nslices = nbSlices;
  temporal.st.tr = TR;
  temporal.st.ta = TA;
  temporal.st.so = sliceOrder * 1000;
  temporal.st.refslice = referenceSlice * 1000;

  expectedBatch{1}.spm.temporal = temporal;

end
