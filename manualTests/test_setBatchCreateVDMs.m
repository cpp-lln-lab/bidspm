% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchCreateVDMs %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchCreateVDMsBasic()

  subLabel = '01';

  opt = setOptions('vismotion', subLabel);

  opt.query.acq = '';

  [BIDS, opt] = getData(opt, opt.dir.input);

  matlabbatch = {};
  matlabbatch = setBatchCreateVDMs(matlabbatch, BIDS, opt, subID);

  %   matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj

  %   expectedBatch = returnExpectedBatch(refImage);
  %
  %   assertEqual(matlabbatch, expectedBatch);

end
