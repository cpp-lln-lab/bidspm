% (C) Copyright 2020 bidspm developers

function test_suite = test_setBatchSubjectLevelResults %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSubjectLevelResults_basic()

  % IF
  contrast_name = 'VisMot';
  [subLabel, opt, result] = setUp('vismotion', contrast_name);

  matlabbatch = {};

  % WHEN
  matlabbatch = setBatchSubjectLevelResults(matlabbatch, opt, subLabel, result);

  % THEN
  expectedBatch = {};

  expectedBatch{end + 1}.spm.stats.results.spmmat = {fullfile(opt.dir.stats, ...
                                                              'sub-01', ...
                                                              'stats', ...
                                                              'task-vismotion_space-MNI_FWHM-6', ...
                                                              'SPM.mat')};

  expectedBatch{end}.spm.stats.results.conspec.titlestr = 'VisMot_p-0pt050_k-0_MC-FWE';
  expectedBatch{end}.spm.stats.results.conspec.contrasts = 1;
  expectedBatch{end}.spm.stats.results.conspec.threshdesc = 'FWE';
  expectedBatch{end}.spm.stats.results.conspec.thresh = 0.05;
  expectedBatch{end}.spm.stats.results.conspec.extent = 0;
  expectedBatch{end}.spm.stats.results.conspec.conjunction = 1;
  expectedBatch{end}.spm.stats.results.conspec.mask.none = true();

  expectedBatch{end}.spm.stats.results.units = 1;

  expectedBatch{end}.spm.stats.results.export = [];

  assertEqual(matlabbatch{end}.spm.stats.results.conspec, ...
              expectedBatch{end}.spm.stats.results.conspec);
  assertEqual(matlabbatch{end}.spm.stats.results.units, ...
              expectedBatch{end}.spm.stats.results.units);
  assertEqual(matlabbatch{end}.spm.stats.results.export{1}.png, true);
  assertEqual(matlabbatch{end}.spm.stats.results.export{2}.csv, true);
  assert(isfield(matlabbatch{end}.spm.stats.results.export{3}, 'nidm'));

end

function test_setBatchSubjectLevelResults_missing_contrast_name()

  if isOctave
    return
  end

  [subLabel, opt, result] = setUp('vismotion');

  result.contrasts.name = '';

  matlabbatch = {};
  assertWarning(@()setBatchSubjectLevelResults(matlabbatch, ...
                                               opt, ...
                                               subLabel, ...
                                               result), ...
                'getContrastNb:missingContrastName');

end

function test_setBatchSubjectLevelResults_error_no_matching_contrast()

  if isOctave
    return
  end

  contrast_name = 'NotAContrast';
  [subLabel, opt, result] = setUp('vismotion', contrast_name);

  matlabbatch = {};
  assertWarning(@()setBatchSubjectLevelResults(matlabbatch, ...
                                               opt, ...
                                               subLabel, ...
                                               result), ...
                'getContrastNb:noMatchingContrastName');

end

function [subLabel, opt, result] = setUp(task, contrastName)

  iCon = 1;

  subLabel = '01';

  opt = setOptions(task, subLabel, 'pipelineType', 'stats');

  if nargin > 1
    opt.results(iCon).name = contrastName;
  end

  result = opt.results(iCon);
  result.space = opt.space;
  result.dir = getFFXdir(subLabel, opt);

end
