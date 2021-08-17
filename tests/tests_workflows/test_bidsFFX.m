% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsFFX %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsFfx_fmriprep_no_smoothing()

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

function test_bidsFfx_mni()

  task = {'vislocalizer'}; % 'vismotion'

  for i = 1

    opt = setOptions(task{i});
    opt.space = {'MNI'};

    opt.dir.raw = opt.dir.preproc;

    bidsFFX('specifyAndEstimate', opt);
    %   bidsFFX('contrasts', opt);
    %   bidsResults(opt);

  end

end

function test_bidsFfx_individual()

  task = {'vislocalizer'}; % 'vismotion'

  for i = 1

    opt = setOptions(task{i});
    opt.space = {'individual'};

    opt.dir.raw = opt.dir.preproc;

    bidsFFX('specifyAndEstimate', opt);
    %   bidsFFX('contrasts', opt);
    %   bidsResults(opt);

  end
end

function cleanUp(folder)

  pause(1);

  if isOctave()
    confirm_recursive_rmdir (true, 'local');
  end
  rmdir(folder, 's');

end
