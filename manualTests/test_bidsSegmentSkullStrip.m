% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_bidsSegmentSkullStrip %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsSegmentSkullStripBasic()

  % smoke test

  % directory with this script becomes the current directory
  opt.dataDir = fullfile( ...
                         fileparts(mfilename('fullpath')), ...
                         '..', 'demos',  'MoAE', 'output', 'MoAEpilot');
  % task to analyze
  opt.taskName = 'auditory';
  opt = checkOptions(opt);

  %% Run batches
  checkDependencies();
  reportBIDS(opt);
  bidsCopyRawFolder(opt, 1);
  bidsSegmentSkullStrip(opt);

end
