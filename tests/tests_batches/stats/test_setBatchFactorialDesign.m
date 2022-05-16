% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchFactorialDesign %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchFactorialDesign_basic()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  opt.verbosity = 1;

  matlabbatch = {};

  assertWarning(@()setBatchFactorialDesign(matlabbatch, opt), ...
                'setBatchFactorialDesign:notImplemented');

  return

  % TODO fix group level results

  matlabbatch = setBatchFactorialDesign(matlabbatch, opt);

  % add test to assert default mask is SPM ICV's
  assertEqual(numel(matlabbatch{1}.spm.stats.factorial_design.des.fd.icell.scans), 2);

end
