% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_unit_cleanCrash %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getcleanCrash()

  system('touch spm_001.png');
  system('touch 001.png');

  cleanCrash();

  assertEqual(exist(fullfile(pwd, '001.png'), 'file'), 2);
  assertEqual(exist(fullfile(pwd, 'spm_001.png'), 'file'), 0);

  delete(fullfile(pwd, '001.png'));

end
