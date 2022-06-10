% (C) Copyright 2022 CPP_SPM developers

function testSuite = test_api %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_isMni_basic()

  % initialise (add relevant folders to path)
  cpp_spm;
  cpp_spm('action', 'uninit');
  cpp_spm('action', 'init');
  cpp_spm('action', 'uninit');

  % also adds folder for testing to the path
  cpp_spm('action', 'dev');
  cpp_spm('action', 'uninit');

  % misc
  cpp_spm('action', 'version');

end
