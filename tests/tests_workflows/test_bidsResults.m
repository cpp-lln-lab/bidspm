% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsResults %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsResults_basic()

  %% GIVEN
  opt = setOptions('vislocalizer');
  opt.space = {'MNI'};

  % Specify what ouput we want
  opt.result.Nodes(1) = returnDefaultResultsStructure();

  opt.result.Nodes(1).Level = 'subject';

  opt.result.Nodes(1).Contrasts(1).Name = 'VisMot_gt_VisStat';

  opt.result.Nodes(1).Contrasts(1).MC =  'FWE';
  opt.result.Nodes(1).Contrasts(1).p = 0.05;
  opt.result.Nodes(1).Contrasts(1).k = 5;

  opt.result.Nodes(1).Output.png = true();

  opt.result.Nodes(1).Output.csv = true();

  opt.result.Nodes(1).Output.thresh_spm = true();

  opt.result.Nodes(1).Output.binary = true();

  opt.result.Nodes(1).Output.NIDM_results = true();

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

  rootBasename = ['sub-ctrl01_task-vislocalizer_space-MNI', ...
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
