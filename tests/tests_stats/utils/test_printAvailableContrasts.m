function test_suite = test_printAvailableContrasts %#ok<*STOUT>

  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_printAvailableContrasts_basic()

  opt = setTestCfg();

  SPM.xCon(1, 1).name = 'foo';
  SPM.xCon(2, 1).name = 'bar';
  SPM.xCon(3, 1).name = 'foobar';

  printAvailableContrasts(SPM, opt);

  tmpDir = tempName();

  save(fullfile(tmpDir, 'SPM.mat'), 'SPM');

  printAvailableContrasts(fullfile(tmpDir, 'SPM.mat'), opt);

  printAvailableContrasts(SPM);

end
