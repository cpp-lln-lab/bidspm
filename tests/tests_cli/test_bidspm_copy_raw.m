function test_suite = test_bidspm_copy_raw %#ok<*STOUT>

  % (C) Copyright 2023 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_copy_anat_only()

  inputPath = fullfile(getMoaeDir(), 'inputs', 'raw');

  outputPath = tempName();

  bidspm(inputPath, outputPath, 'subject', ...
         'action', 'copy', ...
         'anat_only', true, ...
         'verbosity', 0);

  BIDS = bids.layout(fullfile(outputPath, 'derivatives', 'bidspm-preproc'), ...
                     'verbose', false, ...
                     'use_schema', false);

  assertEqual(numel(bids.query(BIDS, 'data')), 1);

end
