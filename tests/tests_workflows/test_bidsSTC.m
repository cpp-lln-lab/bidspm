% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsSTC %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsStc_basic()

  opt = setOptions('vismotion', '');

  opt.query.acq = '';

  matlabbatch = bidsSTC(opt);

  assertEqual(numel(matlabbatch), 1);

end

function test_bidsStc_dual_task()

  opt = setOptions({'vismotion', 'rest'}, '');

  opt.query.acq = '';

  matlabbatch = bidsSTC(opt);

  assertEqual(numel(matlabbatch), 2);

  nbRunsVismotion = 4;
  assertEqual(numel(matlabbatch{1}.spm.temporal.st.scans), nbRunsVismotion);

  nbRunsRest = 2;
  assertEqual(numel(matlabbatch{2}.spm.temporal.st.scans), nbRunsRest);

end

function test_bidsStc_skip()

  opt = setOptions('vislocalizer', '');

  matlabbatch = bidsSTC(opt);

  assertEqual(numel(matlabbatch), 0);

end
