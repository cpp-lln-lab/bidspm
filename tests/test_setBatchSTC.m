function test_suite = test_setBatchSTC %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSTCEmpty()

  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.taskName = 'vislocalizer';

  opt = checkOptions(opt);

  [~, opt, BIDS] = getData(opt);

  subID = '02';
  matlabbatch = [];
  matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subID);

  % no slice timing info for this run so nothing should be returned.
  assertEqual(matlabbatch, []);

end

function test_setBatchSTCForce()

  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.taskName = 'vislocalizer';
  % we give it some slice timing value to force slice timing to happen
  opt.sliceOrder = 1:5;
  opt.STC_referenceSlice = 1.24 / 2;

  opt = checkOptions(opt);

  [~, opt, BIDS] = getData(opt);

  subID = '02';

  matlabbatch = [];
  matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subID);

  TR = 1.55;
  expectedBatch = returnExpectedBatch(opt.sliceOrder, opt.STC_referenceSlice, TR);

  runCounter = 1;
  for iSes = 1:2
    fileName = spm_BIDS(BIDS, 'data', ...
                        'sub', subID, ...
                        'ses', sprintf('0%i', iSes), ...
                        'task', opt.taskName, ...
                        'type', 'bold');
    expectedBatch{1}.spm.temporal.st.scans{runCounter} = {fileName{1}};
    runCounter = runCounter + 1;
  end

  assertEqual(matlabbatch, expectedBatch);

end

function test_setBatchSTCBasic()

  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.taskName = 'vismotion';

  opt = checkOptions(opt);

  [~, opt, BIDS] = getData(opt);

  subID = '02';

  matlabbatch = [];
  matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subID);

  TR = 1.5;
  sliceOrder = repmat([ ...
                       0.5475, 0, 0.3825, 0.055, 0.4375, 0.11, 0.4925, 0.22, 0.6025, ...
                       0.275, 0.6575, ...
                       0.3275, 0.71, 0.165], 1, 3)';
  STC_referenceSlice = 0.355;

  expectedBatch = returnExpectedBatch(sliceOrder, STC_referenceSlice, TR);

  runCounter = 1;
  for iSes = 1:2
    fileName = spm_BIDS(BIDS, 'data', ...
                        'sub', subID, ...
                        'ses', sprintf('0%i', iSes), ...
                        'task', opt.taskName, ...
                        'type', 'bold');
    expectedBatch{1}.spm.temporal.st.scans{runCounter} = ...
        {fileName{1}};
    expectedBatch{1}.spm.temporal.st.scans{runCounter + 1} = ...
        {fileName{2}};
    runCounter = runCounter + 2;
  end

  assertEqual(matlabbatch, expectedBatch);

end

function expectedBatch = returnExpectedBatch(sliceOrder, referenceSlice, TR)

  nbSlices = length(sliceOrder);
  TA = TR - (TR / nbSlices);

  expectedBatch{1}.spm.temporal.st.nslices = nbSlices;
  expectedBatch{1}.spm.temporal.st.tr = TR;
  expectedBatch{1}.spm.temporal.st.ta = TA;
  expectedBatch{1}.spm.temporal.st.so = sliceOrder;
  expectedBatch{1}.spm.temporal.st.refslice = referenceSlice;

end
