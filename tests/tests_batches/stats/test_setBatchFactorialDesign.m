% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchFactorialDesign %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchFactorialDesign_basic()

  createDummyData();

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  opt.verbosity = 1;

  datasetNode = opt.model.bm.get_nodes('Level', 'dataset');

  matlabbatch = {};

  matlabbatch = setBatchFactorialDesign(matlabbatch, opt, datasetNode{1}.Name);

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

  assertWarning(@()setBatchFactorialDesign(matlabbatch, opt, datasetNode{1}.Name), ...
                'setBatchFactorialDesign:notImplemented');

end
