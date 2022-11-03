% (C) Copyright 2022 bidspm developers

function test_suite = test_validate %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_validate_skip()

  args.Results.skip_validation = true;
  validate(args);
end

function test_validate_dataset()

  args.Results.skip_validation = false;
  args.Results.bids_dir = pwd;
  assertExceptionThrown(@() validate(args), 'validate:invalidBidsDataset');

end

function test_validate_quiet()

  opt = setOptions('MoAE');

  args.Results.skip_validation = false;
  args.Results.action = 'preproc';
  args.Results.bids_dir = opt.dir.raw;
  args.Results.verbosity = 0;

  validate(args);

end

function test_validate_model()

  opt = setOptions('MoAE');

  args.Results.skip_validation = false;
  args.Results.action = 'stats';
  args.Results.bids_dir = opt.dir.raw;
  args.Results.model_file = fullfile(opt.dir.raw, '..', '..', 'models');
  args.Results.verbosity = 3;

  validate(args);

end

function test_validate_model_warning()

  opt = setOptions('MoAE');

  args.Results.skip_validation = false;
  args.Results.action = 'stats';
  args.Results.bids_dir = opt.dir.raw;
  args.Results.model_file = fullfile(returnRootDir(), 'demos', 'transformers', 'models');
  args.Results.verbosity = 3;

  assertWarning(@() validate(args), 'validate:invalidModel');

end
