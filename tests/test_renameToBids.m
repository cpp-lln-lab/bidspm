% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_renameToBids %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_renameToBidsBasic()

  opt = setOptions('MoAE-preproc');
  FWHM = 6;

  renameToBids(opt, FWHM);

end
