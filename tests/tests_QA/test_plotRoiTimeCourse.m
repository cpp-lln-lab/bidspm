function test_suite = test_plotRoiTimeCourse %#ok<*STOUT>
  %
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_plotRoiTimeCourse_basic()

  close all;

  % GIVEN
  timeCourseFile = fullfile(getDummyDataDir(), 'mat_files', 'hemi-L_label-V1d_timecourse.tsv');

  % WHEN
  plotRoiTimeCourse(timeCourseFile);

  close all;

end
