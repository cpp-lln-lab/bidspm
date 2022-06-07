% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchFactorialDesign %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchFactorialDesign_within_group()

  createDummyData();

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizerWithinGroup_smdl');
  opt.model.bm = BidsModel('file', opt.model.file);

  datasetNode = opt.model.bm.get_nodes('Name', 'within_group');

  matlabbatch = {};

  matlabbatch = setBatchFactorialDesign(matlabbatch, opt, datasetNode.Name);

  %   % (2 contrasts + 2 dummy contrasts) passed all the way from run level * 2
  %   % batches (design specification + figure design matrix)
  %   assertEqual(numel(matlabbatch), 8);
  %
  %   % add test to assert default mask is SPM ICV's
  %   assertEqual(numel(matlabbatch{1}.spm.stats.factorial_design.des.fd.icell.scans), 2);
  %   assertEqual(matlabbatch{1}.spm.stats.factorial_design.masking.em{1}, ...
  %               spm_select('FPList', fullfile(spm('dir'), 'tpm'), 'mask_ICV.nii'));

end

function test_setBatchFactorialDesign_complex()

  createDummyData();

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vismotionSeveralDatasetLevel_smdl');

  opt.model.bm = BidsModel('file', opt.model.file);

  datasetNode = opt.model.bm.get_nodes('Name', 'simple contrast');

  matlabbatch = {};
  matlabbatch = setBatchFactorialDesign(matlabbatch, opt, datasetNode.Name);

  basedirName = 'task-vismotion_space-IXI549Space_FWHM-6_conFWHM-0_';

  % (2 dummy contrasts) specified at the dataset level * 2
  % batches (design specification + figure design matrix)
  assertEqual(numel(matlabbatch), 4);

  % check that directory name contains:
  % desc-Node(dataset).name_contrast_contrastName
  [~, dir] = fileparts(matlabbatch{1}.spm.stats.factorial_design.dir{1});
  assertEqual(dir, ...
              [basedirName 'desc-simpleContrast_contrast-VisMot']);

  datasetNode = opt.model.bm.get_nodes('Name', 'complex contrast');

  matlabbatch = {};
  matlabbatch = setBatchFactorialDesign(matlabbatch, opt, datasetNode.Name);

  % (1 contrasts) specified at the dataset level * 2
  % batches (design specification + figure design matrix)
  assertEqual(numel(matlabbatch), 2);

  % check that directory name contains:
  % desc-Node(dataset).name_contrast_contrastName
  [~, dir] = fileparts(matlabbatch{1}.spm.stats.factorial_design.dir{1});
  assertEqual(dir, ...
              [basedirName 'desc-complexContrast_contrast-VisMotGtVisStat']);

end

function test_setBatchFactorialDesign_basic()

  createDummyData();

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  datasetNode = opt.model.bm.get_nodes('Level', 'dataset');

  matlabbatch = {};

  matlabbatch = setBatchFactorialDesign(matlabbatch, opt, datasetNode.Name);

  % (2 contrasts + 2 dummy contrasts) passed all the way from run level * 2
  % batches (design specification + figure design matrix)
  assertEqual(numel(matlabbatch), 8);

  % add test to assert default mask is SPM ICV's
  assertEqual(numel(matlabbatch{1}.spm.stats.factorial_design.des.fd.icell.scans), 2);
  assertEqual(matlabbatch{1}.spm.stats.factorial_design.masking.em{1}, ...
              spm_select('FPList', fullfile(spm('dir'), 'tpm'), 'mask_ICV.nii'));

end

function test_setBatchFactorialDesign_wrong_model_design_matrix()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  opt.verbosity = 1;

  datasetNode = opt.model.bm.get_nodes('Level', 'dataset');

  opt.model.bm.Nodes{3}.Model.X = {'gain'};

  matlabbatch = {};

  assertWarning(@()setBatchFactorialDesign(matlabbatch, opt, datasetNode.Name), ...
                'setBatchFactorialDesign:notImplemented');

end
