% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_setBatchGroupLevelContrasts %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchGroupLevelContrasts_no_contrasts()

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  rfxDir = getRFXdir(opt);

  grpLvlCon = struct([]);

  matlabbatch = {};
  assertExceptionThrown(@()setBatchGroupLevelContrasts(matlabbatch, opt, grpLvlCon, rfxDir), ...
                        'setBatchGroupLevelContrasts:noGroupLevelContrast');

end

function test_setBatchGroupLevelContrasts_smoke_test()

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  opt.verbosity = 1;

  rfxDir = getRFXdir(opt);

  grpLvlCon = opt.model.bm.get_dummy_contrasts('Level', 'dataset');

  matlabbatch = {};

  assertWarning(@()setBatchGroupLevelContrasts(matlabbatch, opt, grpLvlCon, rfxDir), ...
                'setBatchGroupLevelContrasts:notImplemented');

  return

  % TODO fix group level results

  matlabbatch = setBatchGroupLevelContrasts(matlabbatch, opt, grpLvlCon, rfxDir); %#ok<UNRCH>

  assertEqual(numel(matlabbatch), 4);

  path_parts = strsplit(matlabbatch{1}.spm.stats.con.spmmat{1}, filesep);
  expected_rfx_folder = 'VisMot';
  assertEqual(path_parts{end - 1}, expected_rfx_folder);

end
