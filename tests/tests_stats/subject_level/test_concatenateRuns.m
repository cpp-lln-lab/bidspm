function test_suite = test_concatenateRuns %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_concatenateRuns_basic()

  matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
  matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
  matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
  matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 5;
  matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 97;
  matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 48;
  matlabbatch{1}.spm.stats.fmri_spec.dir = {''};
  matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
  matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
  matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
  matlabbatch{1}.spm.stats.fmri_spec.cvi = 'FAST';
  matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = {'_bold.nii'};
  matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {'_onsets.mat'};
  matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {'_regressors.mat'};
  matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
  matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond = struct('name', {}, 'onset', {}, 'duration', {});
  matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 125;
  matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = {'_bold.nii'};
  matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi = {'_onsets.mat'};
  matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = {'_regressors.mat'};
  matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress = struct('name', {}, 'val', {});
  matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond = struct('name', {}, 'onset', {}, 'duration', {});
  matlabbatch{1}.spm.stats.fmri_spec.sess(2).hpf = 125;
  matlabbatch{1}.spm.stats.fmri_spec.mask = {'_mask.nii'};

  matlabbatch = {};
  matlabbatch = concatenateRuns_basic(matlabbatch);

end
