% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsGenerateT1map %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsGenerateT1map_basic()

  markTestAs('slow');

  opt = setOptions('vismotion');

  matlabbatch = bidsGenerateT1map(opt);

  assertEqual(numel(matlabbatch), 1);

end
