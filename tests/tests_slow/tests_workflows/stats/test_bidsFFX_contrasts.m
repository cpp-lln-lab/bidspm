function test_suite = test_bidsFFX_contrasts %#ok<*STOUT>
  % (C) Copyright 2021 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsFFX_contrasts_select_node()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');
  opt.stc.skip = 1;

  matlabbatch = bidsFFX('contrasts', opt, ...
                        'nodeName', 'subject_level');

  assertEqual(numel(matlabbatch{1}.spm.stats.con.consess), 4);

end

function test_bidsFFX_contrasts_basic()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');
  opt.stc.skip = 1;

  [matlabbatch, opt] = bidsFFX('contrasts', opt);

  assertEqual(numel(matlabbatch{1}.spm.stats.con.consess), 8);

  assertEqual(opt.dir.jobs, fullfile(opt.dir.stats, 'jobs', 'vislocalizer'));

end
