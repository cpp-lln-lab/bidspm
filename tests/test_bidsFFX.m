% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsFFX %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsFFXBasic()

  opt = setOptions('MoAE-preproc');
  opt.space = {'MNI'};

  opt.pipeline.type = 'stats';
  opt.pipeline.name = 'cpp_spm';

  opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');

  bidsFFX('specifyAndEstimate', opt);
  %   bidsFFX('contrasts', opt);
  %   bidsResults(opt);

end
