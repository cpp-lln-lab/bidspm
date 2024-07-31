function test_suite = test_bidsQAmriqc %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_mriqc_basic()

  opt.dir.mriqc = fullfile(getTestDataDir, 'tsv_files');

  bidsQAmriqc(opt, 'T1w');

end
