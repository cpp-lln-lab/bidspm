% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsSpatialPrepro %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsSpatialPrepro_anat_only()

  opt = setOptions('MoAE-preproc');

  opt.segment.force = true;
  opt.anatOnly = true;

  matlabbatch = bidsSpatialPrepro(opt);

  assertEqual(numel(matlabbatch), 9);
  assert(isfield(matlabbatch{1}, 'cfg_basicio'));
  assert(isfield(matlabbatch{2}.spm.spatial, 'preproc'));
  assert(isfield(matlabbatch{3}.spm.util, 'imcalc'));
  assert(isfield(matlabbatch{4}.spm.util, 'imcalc'));
  for i = 5:9
    assert(isfield(matlabbatch{i}.spm.spatial, 'normalise'));
  end

end

function test_bidsSpatialPrepro_basic()

  opt = setOptions('MoAE-preproc');

  % some tweaks because we have dummy data
  opt.funcVoxelDims = [2 2 2];

  matlabbatch = bidsSpatialPrepro(opt);

  assertEqual(numel(matlabbatch), 10);
  assert(isfield(matlabbatch{1}, 'cfg_basicio'));
  assert(isfield(matlabbatch{2}.spm.spatial, 'realignunwarp'));
  assert(isfield(matlabbatch{3}.spm.spatial, 'coreg'));
  assert(isfield(matlabbatch{4}, 'cfg_basicio'));
  for i = 5:10
    assert(isfield(matlabbatch{i}.spm.spatial, 'normalise'));
  end

end

function test_bidsSpatialPrepro_force_segment()

  opt = setOptions('MoAE-preproc');

  opt.segment.force = true;

  % some tweaks because we have dummy data
  opt.funcVoxelDims = [2 2 2];

  matlabbatch = bidsSpatialPrepro(opt);

  assertEqual(numel(matlabbatch), 13);
  assert(isfield(matlabbatch{1}, 'cfg_basicio'));
  assert(isfield(matlabbatch{2}.spm.spatial, 'realignunwarp'));
  assert(isfield(matlabbatch{3}.spm.spatial, 'coreg'));
  assert(isfield(matlabbatch{4}, 'cfg_basicio'));
  assert(isfield(matlabbatch{5}.spm.spatial, 'preproc'));
  assert(isfield(matlabbatch{6}.spm.util, 'imcalc'));
  assert(isfield(matlabbatch{7}.spm.util, 'imcalc'));
  for i = 8:13
    assert(isfield(matlabbatch{i}.spm.spatial, 'normalise'));
  end

end
