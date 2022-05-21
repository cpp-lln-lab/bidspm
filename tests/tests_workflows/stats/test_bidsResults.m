% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsResults %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsResults_error_missing_node()

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  opt.results.contrasts = defaultResultsStructure();

  opt.results.contrasts.nodeName = 'foo';

  assertWarning(@()bidsResults(opt), 'Model:missingNode');

end

function test_bidsResults_subject_lvl()

  createDummyData();

  %% GIVEN
  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  % Specify what ouput we want
  opt.results.contrasts = defaultResultsStructure();

  opt.results.contrasts.nodeName = 'subject_level';

  opt.results.contrasts.name = {'VisMot_gt_VisStat'};

  opt.results.contrasts.MC =  'FWE';
  opt.results.contrasts.p = 0.05;
  opt.results.contrasts.k = 5;

  opt.results.contrasts.png = true();

  opt.results.contrasts.csv = true();

  opt.results.contrasts.threshSpm = true();

  opt.results.contrasts.binary = true();

  opt.results.contrasts.nidm = true();

  %% WHEN
  matlabbatch = bidsResults(opt);

  %% THEN
  expected.titlestr = 'VisMot_gt_VisStat_p-0pt050_k-5_MC-FWE';
  expected.contrasts = 3;
  expected.threshdesc = 'FWE';
  expected.thresh = 0.0500;
  expected.extent = 5;
  expected.conjunction = 1;
  expected.mask.none = true;

  assertEqual(matlabbatch{1}.spm.stats.results.conspec, expected);

  rootBasename = ['sub-ctrl01_task-vislocalizer_space-IXI549Space', ...
                  '_desc-VisMotGtVisStat_label-0003', ...
                  '_p-0pt050_k-5_MC-FWE'];
  expected = {struct('png', true), ...
              struct('csv', true), ...
              struct('tspm', struct('basename', [rootBasename '_spmT'])), ...
              struct('binary', struct('basename', [rootBasename '_mask'])), ...
              struct('nidm', struct('modality', 'FMRI', ...
                                    'refspace', 'ixi', ...
                                    'group', struct('nsubj', 1, 'label', 'ctrl01'))) ...
             };

  assertEqual(numel(matlabbatch{1}.spm.stats.results.export), 5);

  for i = 1:numel(expected)
    assertEqual(matlabbatch{1}.spm.stats.results.export{i}, expected{i});
  end

  assertEqual(matlabbatch{1}.spm.stats.results.export{3}.tspm.basename, ...
              expected{3}.tspm.basename);

  assertEqual(matlabbatch{1}.spm.stats.results.export{4}.binary.basename, ...
              expected{4}.binary.basename);

end

function test_bidsResults_no_background_for_montage()

  createDummyData();

  %% GIVEN
  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  % Specify what ouput we want
  opt.results.contrasts = defaultResultsStructure();

  opt.results.contrasts.nodeName = 'subject_level';

  opt.results.contrasts.name = {'VisMot_gt_VisStat'};

  opt.results.contrasts.MC =  'FWE';
  opt.results.contrasts.p = 0.05;
  opt.results.contrasts.k = 5;

  opt.results.contrasts.montage.do = true;
  opt.results.contrasts.montage.background = 'aFileThatDoesNotExist.nii';

  assertExceptionThrown(@()bidsResults(opt), 'setMontage:backgroundImageNotFound');

end
