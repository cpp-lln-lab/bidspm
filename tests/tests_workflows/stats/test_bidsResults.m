% (C) Copyright 2024 bidspm developers

function test_suite = test_bidsResults %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsResults_filter_by_nodeName_empty()

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  opt.results = defaultResultsStructure();

  opt.results.nodeName = 'subject_level';

  bidsResults(opt, 'nodeName', 'foo');

end

function test_bidsResults_error_missing_node()

  opt = setOptions('vismotion', '', 'pipelineType', 'stats');

  opt.results = defaultResultsStructure();

  opt.results.nodeName = 'egg';
  opt.results.name = {'spam'};

  assertWarning(@()bidsResults(opt), 'Model:missingNode');

end

function test_bidsResults_no_results()

  skipIfOctave('mixed-string-concat warning thrown');

  opt = setOptions('vismotion', '', 'pipelineType', 'stats');
  opt.verbosity = 1;

  opt = rmfield(opt, 'results');

  assertWarning(@() bidsResults(opt), 'bidsResults:noResultsAsked');

end

function test_bidsResults_one_way_anova_results()

  opt = setOptions('3_groups', '', 'pipelineType', 'stats');

  opt.model.bm = BidsModel('file', opt.model.file);
  opt.verbosity = 0;

  nodeName = 'between_groups';

  contrastName = 'VisMot_gt_VisStat';
  rfxDir = getRFXdir(opt, nodeName, contrastName, '1WayANOVA');
  spm_mkdir(rfxDir);
  xCon(1) = struct('name', 'relative_gt_ctrl');
  xCon(2) = struct('name', 'blind_gt_relative');
  SPM = struct('nscan', 10, 'xCon', xCon);
  save(fullfile(rfxDir, 'SPM.mat'), 'SPM');

  contrastName = 'VisStat_gt_VisMot';
  rfxDir = getRFXdir(opt, nodeName, contrastName, '1WayANOVA');
  spm_mkdir(rfxDir);
  % here we switch the order of the contrast in the SPM.mat
  % to make sure the batch setting picks up the correct ones.
  xCon(2) = struct('name', 'relative_gt_ctrl');
  xCon(1) = struct('name', 'blind_gt_relative');
  SPM = struct('nscan', 10, 'xCon', xCon);
  save(fullfile(rfxDir, 'SPM.mat'), 'SPM');

  matlabbatch = bidsResults(opt, 'nodeName', nodeName);

  assertEqual(length(matlabbatch), 4);
  assertEqual(matlabbatch{1}.result.name, 'VisMotGtVisStat - relative_gt_ctrl');
  assertEqual(matlabbatch{1}.spm.stats.results.conspec.contrasts, 1);
  assertEqual(matlabbatch{2}.result.name, 'VisStatGtVisMot - relative_gt_ctrl');
  assertEqual(matlabbatch{2}.spm.stats.results.conspec.contrasts, 2);
  assertEqual(matlabbatch{3}.result.name, 'VisMotGtVisStat - blind_gt_relative');
  assertEqual(matlabbatch{3}.spm.stats.results.conspec.contrasts, 2);
  assertEqual(matlabbatch{4}.result.name, 'VisStatGtVisMot - blind_gt_relative');
  assertEqual(matlabbatch{4}.spm.stats.results.conspec.contrasts, 1);

end
