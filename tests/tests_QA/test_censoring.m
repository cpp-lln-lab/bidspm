function test_suite = test_censoring %#ok<*STOUT>
  % (C) Copyright 2023 Remi Gau
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_basic()

  opt = setOptions('vislocalizer');

  input = fullfile(opt.dir.preproc, 'sub-01', 'ses-01', 'func', ...
                   sprintf('rp_sub-01_ses-01_task-vislocalizer_bold.txt'));

  data = spm_load(input);
  censoringRegressors = censoring(data);

  assert(size(censoringRegressors, 2) == 9);

  teardown();

end
