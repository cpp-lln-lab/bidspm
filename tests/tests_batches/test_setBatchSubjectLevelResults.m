% (C) Copyright 2020 CPP_SPM developers

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
  assertEqual(matlabbatch{end}.spm.stats.results.export, ...
              expectedBatch{end}.spm.stats.results.export);

end

function test_setBatchSubjectLevelResults_error_missing_contrast_name()

  [subLabel, opt, result] = setUp('vismotion');

  matlabbatch = {};
  assertExceptionThrown( ...
                        @()setBatchSubjectLevelResults(matlabbatch, ...
                                                       opt, ...
                                                       subLabel, ...
                                                       result), ...
                        'setBatchSubjectLevelResults:missingContrastName');

end

function test_setBatchSubjectLevelResults_error_no_matching_contrast()

  contrast_name = 'NotAContrast';
  [subLabel, opt, result] = setUp('vismotion', contrast_name);

  matlabbatch = {};
  assertWarning( ...
                @()setBatchSubjectLevelResults(matlabbatch, ...
                                               opt, ...
                                               subLabel, ...
                                               result), ...
                'setBatchSubjectLevelResults:noMatchingContrastName');

end

function [subLabel, opt, result] = setUp(task, contrastName)

  iNode = 1;
  iCon = 1;

  subLabel = '01';

  opt = setOptions(task, subLabel);

  opt.space = {'IXI549Space'};

  if nargin > 1
    opt.result.Nodes.Contrasts.Name = contrastName;
  end

  result.dir = getFFXdir(subLabel, opt);

  result.space = opt.space;

  result.Contrasts = opt.result.Nodes(iNode).Contrasts(iCon);
  if isfield(opt.result.Nodes(iNode), 'Output')
    result.Output =  opt.result.Nodes(iNode).Output;
  end

end
