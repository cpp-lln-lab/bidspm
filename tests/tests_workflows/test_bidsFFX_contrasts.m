% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsFFX_contrasts %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsFfx_basic()

  opt = setOptions('vislocalizer');
  opt.space = {'MNI'};

  %   % Specify the result to compute
  %   opt.result.Steps(1) = returnDefaultResultsStructure();
  %
  %   opt.result.Steps(1).Level = 'subject';
  %
  %   opt.result.Steps(1).Contrasts(1).Name = 'VisMot_gt_VisStat';
  %
  %   opt.result.Steps(1).Contrasts(1).MC =  'FWE';
  %   opt.result.Steps(1).Contrasts(1).p = 0.05;
  %   opt.result.Steps(1).Contrasts(1).k = 5;
  %
  %   % Specify how you want your output (all the following are on false by default)
  %   opt.result.Steps(1).Output.png = true();
  %   opt.result.Steps(1).Output.csv = true();
  %   opt.result.Steps(1).Output.thresh_spm = true();
  %   opt.result.Steps(1).Output.binary = true();

  opt.dir.raw = opt.dir.preproc;

  matlabbatch = bidsFFX('contrasts', opt);

  matlabbatch{1}.spm.stats.con;

end
