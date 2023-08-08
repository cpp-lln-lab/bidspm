function test_suite = test_returnContrastImageFile %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_returnContrastImageFile_basic()

  %% GIVEN

  opt = setTestCfg();

  SPM.swd = pwd;
  SPM.xCon(1, 1).name = 'foo';
  SPM.xCon(2, 1).name = 'bar';
  SPM.xCon(3, 1).name = 'foobar';

  conImageFile = returnContrastImageFile(SPM, 'bar');
  assertEqual(conImageFile, {fullfile(pwd, 'con_0002.nii')});

  save(fullfile(pwd, 'SPM.mat'), 'SPM');
  conImageFile = returnContrastImageFile(fullfile(pwd, 'SPM.mat'), 'foobar');
  assertEqual(conImageFile, {fullfile(pwd, 'con_0003.nii')});
  delete(fullfile(pwd, 'SPM.mat'));

end

function test_returnContrastImageFile_several()

  %% GIVEN

  opt = setTestCfg();

  SPM.swd = pwd;
  SPM.xCon(1, 1).name = 'foo';
  SPM.xCon(2, 1).name = 'bar';
  SPM.xCon(3, 1).name = 'foobar';

  conImageFile = returnContrastImageFile(SPM, '.*bar');
  assertEqual(conImageFile, ...
              {fullfile(pwd, 'con_0002.nii'); ...
               fullfile(pwd, 'con_0003.nii')});

end
