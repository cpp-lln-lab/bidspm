function test_suite = test_checkFmriprep %#ok<*STOUT>
  % (C) Copyright 2022 CPP_SPM developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_checkFmriprep_basic()

  BIDS.description.GeneratedBy.Name = 'fMRIPrep';
  BIDS.description.GeneratedBy.Version = '20.0.2';

  assert(checkFmriprep(BIDS));

end

function test_checkFmriprep_not_fmriprep()

  BIDS.description.GeneratedBy.Name = 'foo';
  BIDS.description.GeneratedBy.Version = '20.0.2';

  assertEqual(checkFmriprep(BIDS), false);

end

function test_checkFmriprep_too_old()

  BIDS.description.PipelineDescription.Name = 'fMRIPrep';
  BIDS.description.PipelineDescription.Version = '1.1.2';

  assertEqual(checkFmriprep(BIDS), false);

end
