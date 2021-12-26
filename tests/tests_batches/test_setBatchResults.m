% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchResults %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchResults_basic()

  %% GIVEN
  result.dir = pwd;
  result.label = '01';
  result.nbSubj = 1;
  result.contrastNb = 1;

  result.Contrasts.Name = '';
  result.Contrasts.MC = 'FWE';
  result.Contrasts.p = 0.05;
  result.Contrasts.k = 0;

  %% WHEN
  matlabbatch = {};
  matlabbatch = setBatchResults(matlabbatch, result);

  %% THEN
  expectedBatch = returnBasicExpectedResultsBatch();
  assertEqual(matlabbatch, expectedBatch);

end

function test_setBatchResults_export()

  %% GIVEN
  opt.taskName = 'test';

  Contrasts.Name = 'test';
  Contrasts.MC = 'FDR';
  Contrasts.p = 0.05;
  Contrasts.k = 0;
  opt.result.Steps.Contrasts = Contrasts;

  Output.png = true;
  Output.csv = true;
  Output.thresh_spm = true;
  Output.binary = true;
  Output.NIDM_results =  true;
  opt.result.Steps.Output = Output;

  opt.space = 'individual';

  result = setBatchSubjectLevelResultsMock(opt);

  %% WHEN
  matlabbatch = {};
  matlabbatch = setBatchResults(matlabbatch, result);

  %% THEN
  export{1}.png = true;
  export{2}.csv = true;
  export{3}.tspm.basename = ...
      'sub-01_task-test_space-individual_desc-test_label-XXXX_p-0pt050_k-0_MC-FDR_spmT';
  export{4}.binary.basename = ...
      'sub-01_task-test_space-individual_desc-test_label-XXXX_p-0pt050_k-0_MC-FDR_mask';

  export{5}.nidm.modality = 'FMRI';
  export{end}.nidm.refspace = 'ixi';
  export{end}.nidm.refspace = 'subject';
  export{end}.nidm.group.nsubj = 1;
  export{end}.nidm.group.label = '01';

  assertEqual(matlabbatch{1}.spm.stats.results.export{1}, export{1});
  assertEqual(matlabbatch{1}.spm.stats.results.export{2}, export{2});
  assertEqual(matlabbatch{1}.spm.stats.results.export{3}.tspm, export{3}.tspm);
  assertEqual(matlabbatch{1}.spm.stats.results.export{4}.binary, export{4}.binary);
  assertEqual(matlabbatch{1}.spm.stats.results.export{5}, export{5});

  expectedBatch = returnBasicExpectedResultsBatch();
  expectedBatch{end}.spm.stats.results.conspec.titlestr = returnName(result);
  expectedBatch{end}.spm.stats.results.conspec.threshdesc = 'FDR';
  expectedBatch{end}.spm.stats.results.export = export;
  assertEqual(matlabbatch, expectedBatch);

end

function test_setBatchResults_montage()

  %% GIVEN
  opt.taskName = 'test';

  opt.result.Steps.Contrasts.Name = '';
  opt.result.Steps.Contrasts.MC = 'FWE';
  opt.result.Steps.Contrasts.p = 0.05;
  opt.result.Steps.Contrasts.k = 0;

  opt.result.Steps.Output.montage.do =  true;

  opt.space = 'MNI';

  result = setBatchSubjectLevelResultsMock(opt);

  %% WHEN
  matlabbatch = {};
  matlabbatch = setBatchResults(matlabbatch, result);

  %% THEN
  expectedBatch = returnBasicExpectedResultsBatch();

  expectedBatch{end}.spm.stats.results.conspec.titlestr = returnName(result);
  expectedBatch{end}.spm.stats.results.conspec.threshdesc = 'FWE';

  expectedBatch{end}.spm.stats.results.export{1}.montage.background = ...
      {fullfile(spm('dir'), 'canonical', 'avg152T1.nii')};
  expectedBatch{end}.spm.stats.results.export{end}.montage.orientation = 'axial';
  expectedBatch{end}.spm.stats.results.export{end}.montage.slices = [];

  expectedBatch{end + 1}.spm.util.print.fname = ['Montage' returnName(result)];
  expectedBatch{end}.spm.util.print.fig.figname = 'SliceOverlay';
  expectedBatch{end}.spm.util.print.opts = 'png';

  assertEqual(matlabbatch{1}.spm.stats.results.conspec, expectedBatch{1}.spm.stats.results.conspec);
  assertEqual( ...
              matlabbatch{1}.spm.stats.results.export{1}.montage, ...
              expectedBatch{1}.spm.stats.results.export{1}.montage);

end

function expectedBatch = returnBasicExpectedResultsBatch()

  result.Contrasts.Name = '';
  result.Contrasts.MC = 'FWE';
  result.Contrasts.p = 0.05;
  result.Contrasts.k = 0;

  stats.results.spmmat = {fullfile(pwd, 'SPM.mat')};

  stats.results.conspec.titlestr = returnName(result);
  stats.results.conspec.contrasts = 1;
  stats.results.conspec.threshdesc = 'FWE';
  stats.results.conspec.thresh = 0.05;
  stats.results.conspec.extent = 0;
  stats.results.conspec.conjunction = 1;
  stats.results.conspec.mask.none = true();

  stats.results.units = 1;

  expectedBatch = {};
  expectedBatch{end + 1}.spm.stats = stats;
  expectedBatch{end}.spm.stats.results.export = [];

end

function result = setBatchSubjectLevelResultsMock(opt)

  iStep = 1;

  result.dir = pwd;
  result.label = '01';
  result.nbSubj = 1;
  result.contrastNb = 1;

  entities = struct('sub', '', ...
                    'task', opt.taskName, ...
                    'space', opt.space, ...
                    'desc', '', ...
                    'label', 'XXXX');
  result.outputNameStructure = struct( ...
                                      'suffix', 'spmT', ...
                                      'ext', '.nii', ...
                                      'entities', entities, ...
                                      'p', '', ...
                                      'k', '', ...
                                      'MC', '');

  result.Contrasts =  opt.result.Steps(iStep).Contrasts;
  result.Output =  opt.result.Steps(iStep).Output;
  result.space = opt.space;

end
