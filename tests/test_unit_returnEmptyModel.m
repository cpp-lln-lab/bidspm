% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_unit_returnEmptyModel %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_returnEmptyModelBasic()

  content = returnEmptyModel();

  expectedContent = spm_jsonread(fullfile(fileparts(mfilename('fullpath')), ...
                                          'dummyData', ...
                                          'models', ...
                                          'model-empty_smdl.json'));

  assertEqual(content, expectedContent);

end
