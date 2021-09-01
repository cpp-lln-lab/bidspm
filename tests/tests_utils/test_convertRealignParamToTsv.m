% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_convertRealignParamToTsv %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

% temporary silence till we have standard way to deal with those files

function test_convertRealignParamToTsvBasic()

  opt = setOptions('vislocalizer');

  input = fullfile(opt.dir.preproc, 'sub-01', 'ses-01', 'func', ...
                   'rp_sub-01_ses-01_task-vislocalizer_bold.txt');

  opt = set_spm_2_bids_defaults(opt);

  %   convertRealignParamToTsv(input, opt);

  output = fullfile(opt.dir.preproc, 'sub-01', 'ses-01', 'func', ...
                    'sub-01_ses-01_task-vislocalizer_desc-confounds_regressors.tsv');

  %   assertEqual(exist(output, 'file'), 2);

end
