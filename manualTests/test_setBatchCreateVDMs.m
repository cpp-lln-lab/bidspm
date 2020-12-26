% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_setBatchCreateVDMs %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchCreateVDMsBasic()

  subID = '01';

  opt.taskName = 'vismotion';
  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.taskName = 'vismotion';

  opt = checkOptions(opt);

  [~, opt, BIDS] = getData(opt);

  matlabbatch = [];
  matlabbatch = setBatchCreateVDMs(matlabbatch, BIDS, opt, subID);

  %   matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj

  %   expectedBatch = returnExpectedBatch(refImage);
  %
  %   assertEqual(matlabbatch, expectedBatch);

end
