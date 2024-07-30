% (C) Copyright 2020 bidspm developers

function test_suite = test_setBatchFactorialDesign_3_groups %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchFactorialDesign_between_3_groups()

  opt = setOptions('3_groups', '', 'pipelineType', 'stats');
  opt.verbosity = 0;

  [~, opt] = getData(opt, opt.dir.preproc);

  matlabbatch = {};
  [matlabbatch, ~, ~] = setBatchFactorialDesign(matlabbatch, ...
                                                opt, ...
                                                'between_groups');

end
