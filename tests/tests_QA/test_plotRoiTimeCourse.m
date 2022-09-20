function test_suite = test_plotRoiTimeCourse %#ok<*STOUT>
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

  % GIVEN
  timeCourseFile = fullfile(getDummyDataDir(), 'tsv_files', 'hemi-L_label-V1d_timecourse.tsv');

  % WHEN
  plotRoiTimeCourse(timeCourseFile);
  plotRoiTimeCourse(timeCourseFile, true, 'roiName', 'foo');
  plotRoiTimeCourse(timeCourseFile, true, 'colors', zeros(4, 3));

  close all;

end
