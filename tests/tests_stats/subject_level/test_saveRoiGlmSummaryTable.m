function test_suite = test_saveRoiGlmSummaryTable %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_saveRoiGlmSummaryTable_checks()

  % GIVEN
  eventSpec(1).name = 'motion';
  roiList{1} = 'V1';
  subLabel = '01';
  opt.space = 'IXI549Space';

  opt.glm.roibased.do = false;

  opt =  checkOptions(opt);

  % THEN
  assertExceptionThrown(@() saveRoiGlmSummaryTable(opt, subLabel, roiList, eventSpec), ...
                        'saveRoiGlmSummaryTable:roiBasedAnalysis');

end
