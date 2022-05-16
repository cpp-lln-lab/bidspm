% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsRFX %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRFX_smoke_test()

  createDummyData();

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  matlabbatch = bidsRFX('smoothContrasts', opt);
  assertEqual(numel(matlabbatch), 3); % one batch per subject
  matlabbatch =  bidsRFX('meanAnatAndMask', opt);
  assertEqual(numel(matlabbatch), 2);

  % TODO
  opt.verbosity = 1;

  assertWarning(@()bidsRFX('RFX', opt), ...
                'setBatchFactorialDesign:notImplemented');

  cleanUp(fullfile(opt.dir.output, 'derivatives'));

  return

  % TODO fix group level results

  matlabbatch = bidsRFX('RFX', opt); %#ok<UNRCH>

  nbGroupLevelModels = 4;
  nbBatchPerModel = 1; % compute contrast

  % the batch for (specify, figure, estimate, figure) is overwritten after being
  % run
  assertEqual(numel(matlabbatch), nbGroupLevelModels * nbBatchPerModel);

  cleanUp(fullfile(opt.dir.output, 'derivatives'));

end
