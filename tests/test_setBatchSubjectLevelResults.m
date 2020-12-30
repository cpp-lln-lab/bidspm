function test_suite = test_setBatchSubjectLevelResults %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSubjectLevelResultsBasic()

  iStep = 1;
  iCon = 1;

  subID = '01';
  funcFWHM = 6;

  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.space = 'MNI';
  opt.taskName = 'vismotion';

  opt = setDerivativesDir(opt);
  opt = checkOptions(opt);

  opt.result.Steps.Contrasts.Name = 'VisMot';

  matlabbatch = [];
  matlabbatch = setBatchSubjectLevelResults(matlabbatch, opt, subID, funcFWHM, iStep, iCon);

  expectedBatch = {};

  expectedBatch{end + 1}.spm.stats.results.spmmat = {fullfile(opt.derivativesDir, ...
                                                              'sub-01', ...
                                                              'stats', ...
                                                              'ffx_task-vismotion', ...
                                                              'ffx_space-MNI_FWHM-6', ...
                                                              'SPM.mat')};

  expectedBatch{end}.spm.stats.results.conspec.titlestr = 'VisMot_p-0.050_k-0_MC-FWE';
  expectedBatch{end}.spm.stats.results.conspec.contrasts = 1;
  expectedBatch{end}.spm.stats.results.conspec.threshdesc = 'FWE';
  expectedBatch{end}.spm.stats.results.conspec.thresh = 0.05;
  expectedBatch{end}.spm.stats.results.conspec.extent = 0;
  expectedBatch{end}.spm.stats.results.conspec.conjunction = 1;
  expectedBatch{end}.spm.stats.results.conspec.mask.none = true();

  expectedBatch{end}.spm.stats.results.units = 1;

  expectedBatch{end}.spm.stats.results.export = [];

  assertEqual(matlabbatch, expectedBatch);

end

function test_setBatchSubjectLevelResultsErrorMissingContrastName()

  iStep = 1;
  iCon = 1;

  subID = '01';
  funcFWHM = 6;

  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.space = 'MNI';
  opt.taskName = 'vismotion';

  opt = setDerivativesDir(opt);
  opt = checkOptions(opt);

  matlabbatch = [];
  assertExceptionThrown( ...
                        @()setBatchSubjectLevelResults(matlabbatch, ...
                                                       opt, ...
                                                       subID, ...
                                                       funcFWHM, ...
                                                       iStep, ...
                                                       iCon), ...
                        'setBatchSubjectLevelResults:missingContrastName');

end

function test_setBatchSubjectLevelResultsErrorNoMAtchingContrast()

  iStep = 1;
  iCon = 1;

  subID = '01';
  funcFWHM = 6;

  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.space = 'MNI';
  opt.taskName = 'vismotion';

  opt.result.Steps.Contrasts.Name = 'NotAContrast';

  opt = setDerivativesDir(opt);
  opt = checkOptions(opt);

  matlabbatch = [];
  assertExceptionThrown( ...
                        @()setBatchSubjectLevelResults(matlabbatch, ...
                                                       opt, ...
                                                       subID, ...
                                                       funcFWHM, ...
                                                       iStep, ...
                                                       iCon), ...
                        'setBatchSubjectLevelResults:NoMatchingContrastName');

end
