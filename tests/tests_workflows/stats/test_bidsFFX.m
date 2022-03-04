% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsFFX %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsFFX_individual()

  task = {'vislocalizer'}; % 'vismotion'

  for i = 1

    opt = setOptions(task{i}, '', 'pipelineType', 'stats');
    opt.model.file =  fullfile(getDummyDataDir(),  'models', ...
                               ['model-' strjoin(task, '') 'SpaceIndividual_smdl.json']);
    opt.fwhm.func = 0;
    opt.stc.skip = 1;
    
    if exist(opt.dir.stats, 'dir')
        rmdir(opt.dir.stats, 's');
    end

    [matlabbatch, opt] = bidsFFX('specifyAndEstimate', opt);

    bf = bids.File(matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans{1});
    assertEqual(bf.entities.space, 'individual');
    assertEqual(bf.entities.desc, 'preproc');

    assertEqual(opt.dir.jobs, fullfile(opt.dir.stats, 'jobs', 'vislocalizer'));

  end
  
  createDummyData();
  
end

function test_bidsFFX_skip_subject_no_data()

  opt = setOptions('vislocalizer', '^01', 'pipelineType', 'stats');
  opt.model.file = '';
  opt.space = {'MNI152NLin2009cAsym'};
  opt.stc.skip = 1;

  opt.verbosity = 1;

  assertWarning(@()bidsFFX('specifyAndEstimate', opt), 'bidsFFX:noDataForSubjectGLM');

end

function test_bidsFFX_contrasts()

  createDummyData();

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');
  opt.stc.skip = 1;

  [matlabbatch, opt] = bidsFFX('contrasts', opt);

  assertEqual(numel(matlabbatch{1}.spm.stats.con.consess), 8);

  assertEqual(opt.dir.jobs, fullfile(opt.dir.stats, 'jobs', 'vislocalizer'));

end

function test_bidsFFX_fmriprep_no_smoothing()

  if isGithubCi()
    return
  end

  opt = setOptions('fmriprep', '', 'pipelineType', 'stats');
  

  opt.space = 'MNI152NLin2009cAsym';
  opt.query.space = opt.space; % for bidsCopy only
  opt.fwhm.func = 0;

  opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');

  opt = checkOptions(opt);

  bidsCopyInputFolder(opt, false());

  % No proper valid bids file in derivatives of bids-example

  opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');
  opt.dir.output = opt.dir.stats;

  opt = checkOptions(opt);

  % bidsFFX('specifyAndEstimate', opt);
  % bidsFFX('contrasts', opt);
  % bidsResults(opt);

  cleanUp(opt.dir.preproc);

end

function test_bidsFFX_mni()

  % checks that we read the correct space from the model and get the
  % corresponding data

  task = {'vislocalizer'}; % 'vismotion'

  for i = 1

    opt = setOptions(task{i}, '', 'pipelineType', 'stats');
    opt.stc.skip = 1;
    
    if exist(opt.dir.stats, 'dir')
        rmdir(opt.dir.stats, 's');
    end

    [matlabbatch, opt] = bidsFFX('specifyAndEstimate', opt);

    bf = bids.File(matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans{1});
    assertEqual(bf.entities.space, 'IXI549Space');
    assertEqual(bf.entities.desc, 'smth6');

    assertEqual(opt.dir.jobs, fullfile(opt.dir.stats, 'jobs', 'vislocalizer'));

  end
  
  createDummyData();

end
