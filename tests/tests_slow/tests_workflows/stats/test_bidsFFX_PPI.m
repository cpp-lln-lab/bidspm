% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsFFX_PPI %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsFFX_PPI_basic()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  if bids.internal.is_octave()
    moxunit_throw_test_skipped_exception('set up unzipped files with octave fails');
    % TODO unzip the relevant files first
  end

  opt = setOptions('MoAE-fmriprep', '', 'pipelineType', 'stats');

  tempPath = tempName();

  spm_mkdir(fullfile(tempPath, 'inputs'));
  copyfile(fullfile(opt.dir.fmriprep, '..'), fullfile(tempPath, 'inputs'));

  % use fmriprep output as "preprocessed" data
  % unzipping of desc-preproc should happen seamlessly
  opt.dir.fmriprep = fullfile(tempPath, 'inputs', 'fmriprep');
  opt.dir.preproc = opt.dir.fmriprep;
  opt.dir.input = opt.dir.preproc;

  opt.dir.raw = fullfile(tempPath, 'inputs', 'raw');

  opt.dir.derivatives = fullfile(tempPath, 'derivatives');

  opt.dir.stats = fullfile(opt.dir.derivatives, 'bidspm-stats');
  spm_mkdir(opt.dir.stats);

  opt.dir.output = opt.dir.stats;

  opt.model.bm.Input.space = {'MNI152NLin6Asym'};

  % to avoid having to unzip the mask
  opt.model.bm.Nodes{1}.Model.Options.Mask = [];

  opt.dryRun = false;

  % to work with desc-preproc files
  opt.fwhm.func = 0;

  opt.glm.concatenateRuns = true;

  bidsFFX('specify', opt);
  bidsFFX('estimate', opt);
end
