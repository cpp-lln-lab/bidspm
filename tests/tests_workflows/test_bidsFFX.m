% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsFFX %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsFFX_skip_subject_no_data()

  opt = setOptions('vislocalizer');
  opt.space = {'MNI152NLin2009cAsym'};

  opt.verbosity = 1;

  % required for the test
  opt.dir.raw = opt.dir.preproc;

  assertWarning(@()bidsFFX('specifyAndEstimate', opt), 'bidsFFX:noDataForSubjectGLM');

end

function test_bidsFFX_contrasts()

  opt = setOptions('vislocalizer');
  opt.space = {'IXI549Space'};

  % required for the test
  opt.dir.raw = opt.dir.preproc;

  matlabbatch = bidsFFX('contrasts', opt);

  assertEqual(numel(matlabbatch{1}.spm.stats.con.consess), 8);

end

function test_bidsFFX_fmriprep_no_smoothing()

  if isGithubCi()
    return
  end

  opt = setOptions('fmriprep');

  opt.space = 'MNI152NLin2009cAsym';
  opt.query.space = opt.space; % for bidsCopy only
  opt.fwhm.func = 0;

  opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');
  opt.dir.output = opt.dir.stats;

  opt = checkOptions(opt);

  bidsCopyInputFolder(opt, false());

  % No proper valid bids file in derivatives of bids-example

  % bidsFFX('specifyAndEstimate', opt);
  %   bidsFFX('contrasts', opt);
  %   bidsResults(opt);

  cleanUp(opt.dir.preproc);

end

function test_bidsFFX_mni()

  task = {'vislocalizer'}; % 'vismotion'

  for i = 1

    opt = setOptions(task{i});
    opt.space = {'IXI549Space'};

    opt = dirFixture(opt);

    bidsFFX('specifyAndEstimate', opt);

    cleanUp(fullfile(pwd, 'derivatives'));

  end

end

function test_bidsFFX_individual()

  task = {'vislocalizer'}; % 'vismotion'

  for i = 1

    opt = setOptions(task{i});
    opt.space = {'individual'};

    opt = dirFixture(opt);

    bidsFFX('specifyAndEstimate', opt);

    cleanUp(fullfile(pwd, 'derivatives'));

  end
end

function opt = dirFixture(opt)
  % required for the test
  opt.dir.raw = opt.dir.preproc;

  opt.dir.derivatives = fullfile(pwd, 'derivatives');
  opt.dir.stats = fullfile(pwd, 'derivatives', 'cpp_spm-stats');
  opt = checkOptions(opt);
end
