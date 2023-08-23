function test_suite = test_setBatchInverseNormalize %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchInverseNormalize_warning()

  opt = setOptions('vismotion');

  opt.verbosity = 1;

  BIDS = getLayout(opt);
  subLabel = '99';
  imgToResample = {'foo'};
  matlabbatch = {};
  assertWarning(@()setBatchInverseNormalize(matlabbatch, BIDS, opt, subLabel, imgToResample), ...
                'setBatchInverseNormalize:noDeformationField');

end
