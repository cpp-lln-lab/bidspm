% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsFFX %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsFFX_bug_642()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');
  opt.model.bm = BidsModel('file', opt.model.file);
  opt.model.bm.Input.space = char(opt.model.bm.Input.space);

  tmpDir = tempName();
  opt.dir.stats = fullfile(tmpDir);
  opt.dir.output = opt.dir.stats;

  bidsFFX('specifyAndEstimate', opt);

end

function test_bidsFFX_individual()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  task = {'vislocalizer'}; % 'vismotion'

  for i = 1

    opt = setOptions(task{i}, '', 'pipelineType', 'stats');

    tmpDir = tempName();
    opt.dir.stats = fullfile(tmpDir);
    opt.dir.output = opt.dir.stats;

    opt.model.file =  fullfile(getTestDataDir(),  'models', ...
                               ['model-' strjoin(task, '') 'SpaceIndividual_smdl.json']);
    opt.model.bm = BidsModel('file', opt.model.file);
    opt.fwhm.func = 0;
    opt.stc.skip = 1;

    [matlabbatch, opt] = bidsFFX('specifyAndEstimate', opt);

    bf = bids.File(matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans{1});
    assertEqual(bf.entities.space, 'individual');
    assertEqual(bf.entities.desc, 'preproc');

    assertEqual(opt.dir.jobs, fullfile(opt.dir.stats, 'jobs', 'vislocalizer'));

  end

end

function test_bidsFFX_skip_subject_no_data()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('vislocalizer', '^01', 'pipelineType', 'stats');

  tmpDir = tempName();
  opt.dir.stats = fullfile(tmpDir);
  opt.dir.output = opt.dir.stats;

  opt.model.file =  fullfile(getTestDataDir(),  'models', ...
                             'model-vislocalizerWrongSpace_smdl.json');
  opt.model.bm = BidsModel('file', opt.model.file);
  opt.stc.skip = 1;
  opt.model.bm.verbose = false;

  opt.verbosity = 1;

  if bids.internal.is_octave()
    %  warning 'getOptionsFromModel:modelOverridesOptions' was raised,
    %    expected 'bidsFFX:noDataForSubjectGLM'
    return
  end

  assertWarning(@()bidsFFX('specifyAndEstimate', opt), 'bidsFFX:noDataForSubjectGLM');

end

function test_bidsFFX_fmriprep_no_smoothing()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  if bids.internal.is_github_ci()
    moxunit_throw_test_skipped_exception('skip on github CI');
  end

  opt = setOptions('fmriprep', '', 'pipelineType', 'stats');

  opt.space = 'MNI152NLin2009cAsym';
  opt.query.space = opt.space; % for bidsCopy only
  opt.fwhm.func = 0;

  opt.dir.preproc = fullfile(opt.dir.derivatives, 'bidspm-preproc');

  opt = checkOptions(opt);

  bidsCopyInputFolder(opt, 'unzip', false);

  % No proper valid bids file in derivatives of bids-example

  opt.dir.stats = fullfile(opt.dir.derivatives, 'bidspm-stats');
  opt.dir.output = opt.dir.stats;
  opt.model.bm = BidsModel('file', opt.model.file);

  opt = checkOptions(opt);

  % bidsFFX('specifyAndEstimate', opt);
  % bidsFFX('contrasts', opt);
  % bidsResults(opt);

  cleanUp(opt.dir.preproc);

end

function test_bidsFFX_mni()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  % checks that we read the correct space from the model and get the
  % corresponding data

  task = {'vislocalizer'}; % 'vismotion'

  for i = 1

    opt = setOptions(task{i}, '', 'pipelineType', 'stats');
    opt.stc.skip = 1;

    tmpDir = tempName();
    opt.dir.stats = fullfile(tmpDir);
    opt.dir.output = opt.dir.stats;

    [matlabbatch, opt] = bidsFFX('specifyAndEstimate', opt);

    bf = bids.File(matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans{1});
    assertEqual(bf.entities.space, 'IXI549Space');
    assertEqual(bf.entities.desc, 'smth6');

    assertEqual(opt.dir.jobs, fullfile(opt.dir.stats, 'jobs', 'vislocalizer'));

  end

end
