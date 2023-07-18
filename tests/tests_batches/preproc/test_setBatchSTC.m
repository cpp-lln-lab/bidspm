% (C) Copyright 2020 bidspm developers

function test_suite = test_setBatchSTC %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_setBatchSTC_dual_task()

  subLabel = '^01';

  opt = setOptions({'vismotion', 'rest'}, subLabel);
  opt.bidsFilterFile.bold.part = 'mag';
  opt.bidsFilterFile.bold.acq = '';

  BIDS = getLayout(opt);

  matlabbatch = {};
  matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);

  nbRunsVismotion = 4;
  assertEqual(numel(matlabbatch{1}.spm.temporal.st.scans), nbRunsVismotion);

end

function test_setBatchSTC_error_different_repetition_time()

  subLabel = '^01';

  opt = setOptions({'vismotion', 'vislocalizer'}, subLabel);

  opt.bidsFilterFile.bold.acq = '';

  BIDS = getLayout(opt);

  matlabbatch = {};
  assertExceptionThrown( ...
                        @()setBatchSTC(matlabbatch, BIDS, opt, subLabel), ...
                        'getAndCheckRepetitionTime:differentRepetitionTime');

end

function test_setBatchSTC_skip()

  subLabel = '^01';

  opt = setOptions('vismotion', subLabel);

  BIDS = getLayout(opt);

  opt.stc.skip = true;

  matlabbatch = {};
  matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);
  assertEqual(matlabbatch, {});

end

function test_setBatchSTC_empty()

  subLabel = '^01';

  opt = setOptions('vislocalizer', subLabel);

  BIDS = getLayout(opt);

  matlabbatch = {};
  matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);

  % no slice timing info for this run so nothing should be returned.
  assertEqual(matlabbatch, {});

end

function test_setBatchSTC_basic()

  subLabel = '^01';

  opt = setOptions('vismotion', subLabel);
  opt.bidsFilterFile.bold.part = 'mag';
  opt.bidsFilterFile.bold.acq = '';

  BIDS = getLayout(opt);

  matlabbatch = {};
  matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);

  TR = 1.5;
  sliceOrder = repmat([0.5475, 0, 0.3825, 0.055, 0.4375, 0.11, 0.4925, 0.22, 0.6025, ...
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
                          'part', 'mag', ...
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

function expectedBatch = returnExpectedBatch(sliceOrder, referenceSlice, TR)

  nbSlices = length(sliceOrder);
  TA = getAcquisitionTime(sliceOrder, TR);

  temporal.st.nslices = nbSlices;
  temporal.st.tr = TR;
  temporal.st.ta = TA;
  temporal.st.so = sliceOrder * 1000;
  temporal.st.refslice = referenceSlice * 1000;

  expectedBatch{1}.spm.temporal = temporal;

end
