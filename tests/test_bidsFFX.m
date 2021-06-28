% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsFFX %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsFFXBasic()

  FWHM = 6;

  opt = setOptions('MoAE-preproc');

  opt.pipeline.type = 'stats';
  opt.pipeline.name = 'cpp_spm-stats';

  opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
  opt.dir.input = opt.dir.preproc;

  bidsFFX('specifyAndEstimate', opt, FWHM);
  %   bidsFFX('contrasts', opt, FWHM);
  %   bidsResults(opt, FWHM);

end
