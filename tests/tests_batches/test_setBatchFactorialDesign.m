% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchFactorialDesign %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchFactorialDesign_basic()

  opt = setOptions('vismotion');
  opt.subjects = {'01' '02'};
  opt.space = {'MNI'};

  matlabbatch = {};
  matlabbatch = setBatchFactorialDesign(matlabbatch, opt);

  % TODO
  % add assert

end
