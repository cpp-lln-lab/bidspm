% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_setBatchSTC %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSTCEmpty()

  subLabel = '02';

  opt = setOptions('vislocalizer', subLabel);

  [BIDS, opt] = getData(opt);

  matlabbatch = [];
  matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);

  % no slice timing info for this run so nothing should be returned.
  assertEqual(matlabbatch, []);

end

function test_setBatchSTCForce()

  subLabel = '02';

  opt = setOptions('vislocalizer', subLabel);

  % we give it some slice timing value to force slice timing to happen
  opt.sliceOrder = linspace(0, 1.6, 10);
  opt.sliceOrder(end - 1:end) = [];
  opt.STC_referenceSlice = 1.6 / 2;

  opt = checkOptions(opt);

  [BIDS, opt] = getData(opt);

  matlabbatch = [];
  matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);

  TR = 1.55;
  expectedBatch = returnExpectedBatch(opt.sliceOrder, opt.STC_referenceSlice, TR);

  runCounter = 1;
  for iSes = 1:2
    fileName = spm_BIDS(BIDS, 'data', ...
                        'sub', subLabel, ...
                        'ses', sprintf('0%i', iSes), ...
                        'task', opt.taskName, ...
                        'type', 'bold');
    expectedBatch{1}.spm.temporal.st.scans{runCounter} = {fileName{1}};
    runCounter = runCounter + 1;
  end

  assertEqual(matlabbatch, expectedBatch);

end

function test_setBatchSTCBasic()

  subLabel = '02';

  opt = setOptions('vismotion', subLabel);
  opt.query = struct('acq', '');

  [BIDS, opt] = getData(opt);

  matlabbatch = [];
  matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);

  TR = 1.5;
  sliceOrder = repmat([ ...
                       0.5475, 0, 0.3825, 0.055, 0.4375, 0.11, 0.4925, 0.22, 0.6025, ...
                       0.275, 0.6575, ...
                       0.3275, 0.71, 0.165], 1, 3)';
  STC_referenceSlice = 0.355;

  expectedBatch = returnExpectedBatch(sliceOrder, STC_referenceSlice, TR);

  runCounter = 1;
  for iSes = 1:2
    fileName = bids.query(BIDS, 'data', ...
                          'sub', subLabel, ...
                          'ses', sprintf('0%i', iSes), ...
                          'task', opt.taskName, ...
                          'type', 'bold', ...
                          'acq', '');
    expectedBatch{1}.spm.temporal.st.scans{runCounter} = ...
        {fileName{1}};
    expectedBatch{1}.spm.temporal.st.scans{runCounter + 1} = ...
        {fileName{2}};
    runCounter = runCounter + 2;
  end

  assertEqual(matlabbatch, expectedBatch);

end

function test_setBatchSTCErrorInvalidInputTime()

  subLabel = '02';

  opt = setOptions('vislocalizer', subLabel);

  opt.sliceOrder = linspace(0, 1.6, 10);
  opt.sliceOrder(end) = [];
  opt.STC_referenceSlice = 2; % impossible reference value

  [BIDS, opt] = getData(opt);

  matlabbatch = [];

  assertExceptionThrown( ...
                        @()setBatchSTC(matlabbatch, BIDS, opt, subLabel), ...
                        'setBatchSTC:invalidInputTime');

end

function expectedBatch = returnExpectedBatch(sliceOrder, referenceSlice, TR)

  nbSlices = length(sliceOrder);
  TA = TR - (TR / nbSlices);
  TA = ceil(TA * 1000) / 1000;

  expectedBatch{1}.spm.temporal.st.nslices = nbSlices;
  expectedBatch{1}.spm.temporal.st.tr = TR;
  expectedBatch{1}.spm.temporal.st.ta = TA;
  expectedBatch{1}.spm.temporal.st.so = sliceOrder * 1000;
  expectedBatch{1}.spm.temporal.st.refslice = referenceSlice * 1000;

end
