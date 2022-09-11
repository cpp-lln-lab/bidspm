% (C) Copyright 2021 bidspm developers

function test_suite = test_convertRealignParamToTsv %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_convertRealignParamToTsv_basic()

  opt = setOptions('vislocalizer');

  input = fullfile(opt.dir.preproc, 'sub-01', 'ses-01', 'func', ...
                   'rp_sub-01_ses-01_task-vislocalizer_bold.txt');

  opt = set_spm_2_bids_defaults(opt);

  convertRealignParamToTsv(input, opt);

  output = fullfile(opt.dir.preproc, 'sub-01', 'ses-01', 'func', ...
                    'sub-01_ses-01_task-vislocalizer_motion.tsv');

  assertEqual(exist(output, 'file'), 2);

end

function test_convertRealignParamToTsv_non_bold_data()

  opt = setOptions('vislocalizer');

  opt.bidsFilterFile.bold.suffix = 'vaso';

  input = fullfile(opt.dir.preproc, 'sub-01', 'ses-01', 'func', ...
                   'rp_sub-01_ses-01_task-vislocalizer_vaso.txt');

  copyfile(fullfile(opt.dir.preproc, 'sub-01', 'ses-01', 'func', ...
                    'rp_sub-01_ses-01_task-vislocalizer_bold.txt'), ...
           input);

  opt = set_spm_2_bids_defaults(opt);

  rpTsvFile = convertRealignParamToTsv(input, opt);

  output = fullfile(opt.dir.preproc, 'sub-01', 'ses-01', 'func', ...
                    'sub-01_ses-01_task-vislocalizer_desc-vasoConfounds_motion.tsv');

  assertEqual(exist(output, 'file'), 2);

  delete(input);

end
