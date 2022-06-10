% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_getTpmFilename %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

% TODO
% add tests to check:
%  - errors when the requested file is not in the correct session
%  - that the function is smart enough to find an anat even when user has not
%    specified a session

function test_getTpmFilename_basic()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel);

  BIDS = getLayout(opt);

  gm = getTpmFilename(BIDS, getAnatFilename(BIDS, opt, subLabel));

  expectedFilename = 'sub-01_ses-01_space-individual_label-GM_probseg.nii';

  assertEqual(spm_file(gm, 'filename'), expectedFilename);

end

function test_getTpmFilename_mni()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel);

  BIDS = getLayout(opt);

  res = 'bold';
  space = 'MNI';
  gm = getTpmFilename(BIDS, getAnatFilename(BIDS, opt, subLabel), res, space);

  expectedFilename = 'sub-01_ses-01_space-IXI549Space_res-bold_label-GM_probseg.nii';

  assertEqual(spm_file(gm, 'filename'), expectedFilename);

end
