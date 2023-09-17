% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsRemoveDummies %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRemoveDummies_basic()

  markTestAs('slow');

  if bids.internal.is_octave()
    tmpDir = fullfile(tempname);
  else
    tmpDir = fullfile(tempname, 'raw');
  end
  spm_mkdir(tmpDir);
  opt = setOptions('MoAE');
  copyfile(opt.dir.raw, tmpDir);

  if bids.internal.is_octave()
    tmpDir = fullfile(tmpDir, 'raw');
  end
  opt.dir.raw = tmpDir;
  opt.dir.input = tmpDir;
  bidsRemoveDummies(opt, 'dummyScans', 20, 'force', false);

end
