% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsResults %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsResults_subject_lvl()

  markTestAs('slow');

  %% GIVEN
  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  % Specify what output we want
  opt.results = defaultResultsStructure();

  opt.results.nodeName = 'subject_level';

  opt.results.name = {'VisMot_gt_VisStat'};

  opt.results.MC =  'FWE';
  opt.results.p = 0.05;
  opt.results.k = 5;
  opt.results.png = true();
  opt.results.csv = true();
  opt.results.threshSpm = true();
  opt.results.binary = true();
  opt.results.nidm = true();

  opt = rmResultsFromModel(opt);

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
                  '_desc-VisMotGtVisStat_p-0pt050_k-5_MC-FWE'];
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

function test_bidsResults_subject_lvl_regex()

  markTestAs('slow');

  %% GIVEN
  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  % Specify what output we want
  opt.results = defaultResultsStructure();

  opt.results.nodeName = 'subject_level';

  opt.results.name = {'.*VisMot.*'};

  opt.subjects = {'01'};

  opt = rmResultsFromModel(opt);

  %% WHEN
  matlabbatch = bidsResults(opt);

  %% THEN
  % 3 contrasts match the regex
  %  'VisMot'
  %  'VisMot_gt_VisStat'
  %  'VisStat_gt_VisMot'
  assertEqual(numel(matlabbatch), 3);

end

function test_bidsResults_filter_by_nodeName()

  markTestAs('slow');

  %% GIVEN
  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  % Specify what output we want
  opt.results = defaultResultsStructure();

  opt.results(1).nodeName = 'subject_level';
  opt.results(1).name = {'VisMot_gt_VisStat'};

  opt.results(2).nodeName = 'dataset_level';
  opt.results(2).name = {'VisMot_gt_VisStat'};

  opt = rmResultsFromModel(opt);

  %% WHEN
  matlabbatch = bidsResults(opt, 'nodeName', 'subject_level');

  %% THEN
  assertEqual(numel(matlabbatch), 1);

end

function test_bidsResults_too_many_backgrounds()

  markTestAs('slow');

  %% GIVEN
  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  % Specify what output we want
  opt.results = defaultResultsStructure();

  opt.results.nodeName = 'subject_level';

  opt.results.name = {'VisMot_gt_VisStat'};

  opt.results.MC =  'FWE';
  opt.results.p = 0.05;
  opt.results.k = 5;

  opt.results.montage.do = true;
  opt.results.montage.background = struct('suffix', 'probseg');

  opt = rmResultsFromModel(opt);

  skipIfOctave('mixed-string-concat warning thrown');
  opt.verbosity = 1;
  assertWarning(@()bidsResults(opt), 'bidsResults:tooManyMontageBackground');

end

function test_bidsResults_background_for_subject()

  markTestAs('slow');

  %% GIVEN
  opt = setOptions('vislocalizer', {'01', 'ctrl01', 'blind01'}, ...
                   'pipelineType', 'stats');

  % Specify what output we want
  opt.results = defaultResultsStructure();

  opt.results.nodeName = 'subject_level';

  opt.results.name = {'VisMot_gt_VisStat'};

  opt.results.MC =  'FWE';
  opt.results.p = 0.05;
  opt.results.k = 5;

  opt.results.montage.do = true;
  opt.results.montage.background = struct('desc', 'preproc', ...
                                          'suffix', 'T1w');

  opt.subjects = {'^01'};

  opt = rmResultsFromModel(opt);

  matlabbatch = bidsResults(opt);

  bf = bids.File(matlabbatch{1}.spm.stats.results.export{4}.montage.background{1});
  assertEqual(bf.entities.desc, 'preproc');
  assertEqual(bf.entities.sub, '01');
  assertEqual(bf.suffix, 'T1w');

  opt.subjects = {'ctrl01'};

  matlabbatch = bidsResults(opt);

  bf = bids.File(matlabbatch{1}.spm.stats.results.export{4}.montage.background{1});
  assertEqual(bf.entities.desc, 'preproc');
  assertEqual(bf.entities.sub, 'ctrl01');
  assertEqual(bf.suffix, 'T1w');
end

function test_bidsResults_no_background_for_montage()

  markTestAs('slow');

  %% GIVEN
  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  % Specify what output we want
  opt.results = defaultResultsStructure();

  opt.results.nodeName = 'subject_level';

  opt.results.name = {'VisMot_gt_VisStat'};

  opt.results.MC =  'FWE';
  opt.results.p = 0.05;
  opt.results.k = 5;

  opt.results.montage.do = true;
  opt.results.montage.background = 'aFileThatDoesNotExist.nii';

  opt = rmResultsFromModel(opt);

  skipIfOctave('mixed-string-concat warning thrown');
  opt.verbosity = 1;
  assertWarning(@()bidsResults(opt), 'checkMaskOrUnderlay:missingMaskOrUnderlay');

end

function test_bidsResults_dataset_lvl()

  markTestAs('slow');

  % TODO requires updating dummy dataset
  return

  %% GIVEN
  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  % Specify what output we want
  opt.results = defaultResultsStructure();

  opt.results.nodeName = 'dataset_level';

  opt.results.name = {'VisMot_gt_VisStat'};

  %% WHEN

  matlabbatch = bidsResults(opt);

end

function opt = rmResultsFromModel(opt)
  for i = 1:numel(opt.model.bm.Nodes)
    opt.model.bm.Nodes{i}.Model.Software = rmfield(opt.model.bm.Nodes{i}.Model.Software, ...
                                                   'bidspm');
  end
end
