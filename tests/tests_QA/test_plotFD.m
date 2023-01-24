function test_suite = test_plotFD %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_plotRoiTimeCourse_basic()

  close all;

  opt = setOptions('vislocalizer');

  input = fullfile(opt.dir.preproc, 'sub-01', 'ses-01', 'func', ...
                   sprintf('rp_sub-01_ses-01_task-vislocalizer_bold.txt'));

  motionParameters = spm_load(input);
  [fd, rms] = computeFDandRMS(motionParameters, 52);
  fdOutliers = computeRobustOutliers(fd);
  rmsOutliers = computeRobustOutliers(rms);

  F = plotRPandFDandRMS(motionParameters, fd, fdOutliers, rms, rmsOutliers, 'on');
  spm_figure('Print', F);
  delete('*.png');
  close all;

end
