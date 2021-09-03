% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchCoregistrationFmap %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchCoregistrationFmap_basic()

  subLabel = '02';

  opt = setOptions('vismotion', subLabel);

  opt.query.acq = '';

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  matlabbatch = {};
  matlabbatch = setBatchCoregistrationFmap(matlabbatch, BIDS, opt, subLabel);

end
