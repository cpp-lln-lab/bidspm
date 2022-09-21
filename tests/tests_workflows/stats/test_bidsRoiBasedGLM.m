function test_suite = test_bidsRoiBasedGLM %#ok<*STOUT>

  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRoiBasedGLM_checks()

  opt = setOptions('vislocalizer', '01', 'pipelineType', 'stats');
  opt.model.bm = BidsModel('file', opt.model.file);
  opt.model.bm.Input.space = char(opt.model.bm.Input.space);

  assertExceptionThrown(@() bidsRoiBasedGLM(opt), 'bidsRoiBasedGLM:roiBasedAnalysis');

end
