function test_suite = test_plotConfounds %#ok<*STOUT>
  % (C) Copyright 2023 Remi Gau
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_plotConfounds_basic()

  close all;

  opt = setOptions('vislocalizer');

  input = fullfile(getTestDataDir, 'tsv_files', ...
                   'sub-01_task-auditory_desc-confounds_timeseries.tsv');

  confounds = bids.util.tsvread(input);

  F = plotConfounds(confounds, 'on');
  spm_figure('Print', F);
  delete('*.png');
  close all;

end
