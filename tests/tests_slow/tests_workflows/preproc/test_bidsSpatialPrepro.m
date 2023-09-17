% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsSpatialPrepro %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsSpatialPrepro_segment_no_skustrip()

  markTestAs('slow');

  opt = setOptions('MoAE-preproc');

  % some tweaks because we have dummy data
  opt.funcVoxelDims = [2 2 2];
  opt.segment.do = true;
  opt.segment.force = true;
  opt.skullstrip.do = false;

  matlabbatch = bidsSpatialPrepro(opt);

  assertEqual(numel(matlabbatch), 10);
  assert(isfield(matlabbatch{1}, 'cfg_basicio'));
  assert(isfield(matlabbatch{2}.spm.spatial, 'realignunwarp'));
  assert(isfield(matlabbatch{3}.spm.spatial, 'coreg'));
  assert(isfield(matlabbatch{4}, 'cfg_basicio'));
  assert(isfield(matlabbatch{5}.spm.spatial, 'preproc'));
  for i = 6:numel(matlabbatch)
    matlabbatch{i}.spm.spatial.normalise.write.subj.resample;
    assert(isfield(matlabbatch{i}.spm.spatial, 'normalise'));
  end

end

function test_bidsSpatialPrepro_basic()

  markTestAs('slow');

  opt = setOptions('MoAE-preproc');

  % some tweaks because we have dummy data
  opt.funcVoxelDims = [2 2 2];
  % dummy data that already contains the output of some segmentation
  % so need to force it to see the whole full behavior of the workflow
  opt.segment.force = true;

  matlabbatch = bidsSpatialPrepro(opt);

  assertEqual(numel(matlabbatch), 14);
  assert(isfield(matlabbatch{1}, 'cfg_basicio'));
  assert(isfield(matlabbatch{2}.spm.spatial, 'realignunwarp'));
  assert(isfield(matlabbatch{3}.spm.spatial, 'coreg'));
  assert(isfield(matlabbatch{4}, 'cfg_basicio'));
  assert(isfield(matlabbatch{5}.spm.spatial, 'preproc'));
  assert(isfield(matlabbatch{6}.spm.util, 'imcalc'));
  assert(isfield(matlabbatch{7}.spm.util, 'imcalc'));
  for i = 8:numel(matlabbatch)
    matlabbatch{i}.spm.spatial.normalise.write.subj.resample;
    assert(isfield(matlabbatch{i}.spm.spatial, 'normalise'));
  end

end

function test_bidsSpatialPrepro_no_normalisation_no_unwarp()

  markTestAs('slow');

  opt = setOptions('MoAE-preproc');

  opt.space = 'individual';
  opt.realign.useUnwarp = false;

  % some tweaks because we have dummy data
  opt.funcVoxelDims = [2 2 2];

  % dummy data that already contains the output of some segmentation
  % so need to force it to see the whole full behavior of the workflow
  opt.segment.force = true;

  matlabbatch = bidsSpatialPrepro(opt);

  assertEqual(numel(matlabbatch), 8);
  assert(isfield(matlabbatch{1}, 'cfg_basicio'));
  assert(isfield(matlabbatch{2}.spm.spatial.realign, 'estwrite'));
  assert(isfield(matlabbatch{3}.spm.spatial, 'coreg'));
  assert(isfield(matlabbatch{4}, 'cfg_basicio'));
  assert(isfield(matlabbatch{5}.spm.spatial, 'preproc'));
  assert(isfield(matlabbatch{6}.spm.util, 'imcalc'));
  assert(isfield(matlabbatch{7}.spm.util, 'imcalc'));
  assert(isfield(matlabbatch{8}.spm.spatial.realign, 'write'));

end

function test_bidsSpatialPrepro_no_normalisation()

  markTestAs('slow');

  opt = setOptions('MoAE-preproc');

  opt.space = 'individual';

  % some tweaks because we have dummy data
  opt.funcVoxelDims = [2 2 2];

  % dummy data that already contains the output of some segmentation
  % so need to force it to see the whole full behavior of the workflow
  opt.segment.force = true;

  matlabbatch = bidsSpatialPrepro(opt);

  assertEqual(numel(matlabbatch), 7);
  assert(isfield(matlabbatch{1}, 'cfg_basicio'));
  assert(isfield(matlabbatch{2}.spm.spatial, 'realignunwarp'));
  assert(isfield(matlabbatch{3}.spm.spatial, 'coreg'));
  assert(isfield(matlabbatch{4}, 'cfg_basicio'));
  assert(isfield(matlabbatch{5}.spm.spatial, 'preproc'));
  assert(isfield(matlabbatch{6}.spm.util, 'imcalc'));
  assert(isfield(matlabbatch{7}.spm.util, 'imcalc'));

end

function test_bidsSpatialPrepro_anat_only()

  markTestAs('slow');

  opt = setOptions('MoAE-preproc');

  opt.segment.force = true;
  opt.anatOnly = true;

  matlabbatch = bidsSpatialPrepro(opt);

  assertEqual(numel(matlabbatch), 10);
  assert(isfield(matlabbatch{1}, 'cfg_basicio'));
  assert(isfield(matlabbatch{2}.spm.spatial, 'preproc'));
  assert(isfield(matlabbatch{3}.spm.util, 'imcalc'));
  assert(isfield(matlabbatch{4}.spm.util, 'imcalc'));
  for i = 5:numel(matlabbatch)
    matlabbatch{i}.spm.spatial.normalise.write.subj.resample;
    assert(isfield(matlabbatch{i}.spm.spatial, 'normalise'));
  end

end

function test_bidsSpatialPrepro_force_segment()

  markTestAs('slow');

  opt = setOptions('MoAE-preproc');

  opt.segment.force = true;

  % some tweaks because we have dummy data
  opt.funcVoxelDims = [2 2 2];

  matlabbatch = bidsSpatialPrepro(opt);

  assertEqual(numel(matlabbatch), 14);
  assert(isfield(matlabbatch{1}, 'cfg_basicio'));
  assert(isfield(matlabbatch{2}.spm.spatial, 'realignunwarp'));
  assert(isfield(matlabbatch{3}.spm.spatial, 'coreg'));
  assert(isfield(matlabbatch{4}, 'cfg_basicio'));
  assert(isfield(matlabbatch{5}.spm.spatial, 'preproc'));
  assert(isfield(matlabbatch{6}.spm.util, 'imcalc'));
  assert(isfield(matlabbatch{7}.spm.util, 'imcalc'));
  for i = 8:numel(matlabbatch)
    assert(isfield(matlabbatch{i}.spm.spatial, 'normalise'));
  end

end
