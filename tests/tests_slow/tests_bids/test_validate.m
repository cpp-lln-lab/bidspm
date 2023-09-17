% (C) Copyright 2022 bidspm developers

function test_suite = test_validate %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_validate_dataset()

  markTestAs('slow');

  if bids.internal.is_octave()
    return
  end

  args.Results.skip_validation = false;
  args.Results.bids_dir = pwd;
  assertExceptionThrown(@() validate(args), 'validate:invalidBidsDataset');

end
