% (C) Copyright 2020 bidspm developers

function test_suite = test_setBatchGenerateT1map %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchGenerateT1map_basic()

  subLabel = '^01';

  opt = setOptions('vismotion', subLabel);

  BIDS = getLayout(opt);

  matlabbatch = {};
  matlabbatch = setBatchGenerateT1map(matlabbatch, BIDS, opt, subLabel);

  estimateT1 = matlabbatch{1}.spm.tools.mp2rage.estimateT1;
  estimateT1 = rmfield(estimateT1, 'UNI');

  expected.B0 = 7;
  expected.TR = 4.3;
  expected.TI = [1 3.2];
  expected.FA = [4 4];
  expected.nrSlices = nan;
  expected.PartialFourierInSlice = 0.75;
  expected.EchoSpacing = 0.0072;
  expected.FatSat = 'yes';
  expected.outputT1.prefix = 'qT1';
  expected.outputR1.prefix = 'qR1';

  assertEqual(estimateT1, expected);

end

function test_setBatchGenerateT1map_warning()

  skipIfOctave('mixed-string-concat warning thrown');

  subLabel = '^01';

  opt = setOptions('vismotion', subLabel);

  BIDS = getLayout(opt);

  matlabbatch = {};
  opt.verbosity = 1;
  assertWarning(@() setBatchGenerateT1map(matlabbatch, BIDS, opt, subLabel), ...
                'setBatchGenerateT1map:missingNonBIDSMetadata');

end
