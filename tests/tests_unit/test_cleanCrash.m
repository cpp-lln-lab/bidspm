function test_suite = test_cleanCrash %#ok<*STOUT>
  % (C) Copyright 2020 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_cleanCrash_basic()

  tmpDir = tempName();
  PWD = pwd;
  cd(tmpDir);

  touch('spm_001.png');
  touch('001.png');

  cleanCrash();

  assertEqual(exist(fullfile(tmpDir, '001.png'), 'file'), 2);
  assertEqual(exist(fullfile(tmpDir, 'spm_001.png'), 'file'), 0);

  cd(PWD);

end
