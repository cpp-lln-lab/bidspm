% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsSTC %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsStc_dual_task()

  % Cannot test dual task for now as rest and vismotion
  % do not have the same entities (rest has no part entity)
  %   opt = setOptions({'vismotion', 'rest'}, '');
  opt = setOptions({'vismotion'}, '^01');

  opt.bidsFilterFile.bold.acq = '';
  opt.bidsFilterFile.bold.part = 'mag';

  matlabbatch = bidsSTC(opt);

  assertEqual(numel(matlabbatch), 1);

  nbRunsVismotion = 4;
  assertEqual(numel(matlabbatch{1}.spm.temporal.st.scans), nbRunsVismotion);

  %   nbRunsRest = 1;
  %   assertEqual(numel(matlabbatch{2}.spm.temporal.st.scans), nbRunsRest);

end

function test_bidsStc_basic()

  opt = setOptions('vismotion', '^01');

  opt.bidsFilterFile.bold.acq = '';

  matlabbatch = bidsSTC(opt);

  assertEqual(numel(matlabbatch), 1);

end

function test_bidsStc_skip()

  opt = setOptions('vislocalizer', '^01');

  warning OFF;
  matlabbatch = bidsSTC(opt);
  warning ON;

  assertEqual(numel(matlabbatch), 0);

end
