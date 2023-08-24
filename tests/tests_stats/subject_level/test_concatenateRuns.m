function test_suite = test_concatenateRuns %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_concatenateRuns_basic()

  tempPath = tempName();

  imageSrc = fullfile(getMoaeDir(), 'inputs', 'raw', ...
                      'sub-01', 'func', 'sub-01_task-auditory_bold.nii');

  %% run 1
  names =     {'foo',    'bar'};
  onsets =    {[1; 10],  [3; 8]};
  durations = {[2; 2.5], [3; 0]};
  pmod = struct('name', {''}, 'param', {}, 'poly', {});
  onsetFile1 = fullfile(tempPath, 'sub-01_ses-01_task-fiz_run-1_onsets.mat');
  save(onsetFile1, ...
       'names', 'onsets', 'durations', 'pmod', ...
       '-v7');

  names =  {'rot_x',    'trans_x', 'csf',     'white'};
  R =      rand(6, 4);
  regressorsFile1 = fullfile(tempPath, 'sub-01_ses-01_task-fiz_run-1_timeseries.mat');
  save(regressorsFile1, 'names', 'R', '-v7');

  image1 = fullfile(tempPath, 'sub-01_task-auditory_run-1_bold.nii');
  copyfile(imageSrc, image1);

  %% run 2
  names =     {'foo',    'bar',  'alp'};
  onsets =    {[1; 10],  [3; 8], [4; 11]};
  durations = {[2; 2.5], [3; 0], [1; 2]};
  pmod = struct('name', {''}, 'param', {}, 'poly', {});
  onsetFile2 = fullfile(tempPath, 'sub-01_ses-02_task-buzz_run-1_onsets.mat');
  save(onsetFile2, ...
       'names', 'onsets', 'durations', 'pmod', ...
       '-v7');

  names =  {'rot_x',    'trans_x',  'motion_1'};
  R =      [rand(4, 2), [1; zeros(3, 1)]];
  regressorsFile2 = fullfile(tempPath, 'sub-01_ses-02_task-buzz_run-1_timeseries.mat');
  save(regressorsFile2, 'names', 'R', '-v7');

  image2 = fullfile(tempPath, 'sub-01_task-auditory_run-02_bold.nii');
  copyfile(imageSrc, image2);

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

  matlabbatch{1}.spm.stats.fmri_spec.mask = {''};

  matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = {image1};
  matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {onsetFile1};
  matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {regressorsFile1};
  matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
  matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond = struct('name', {}, 'onset', {}, 'duration', {});
  matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 125;

  % one run does nothing
  newMatlabbatch = concatenateRuns(matlabbatch);
  assertEqual(newMatlabbatch, matlabbatch);

  matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = {image2};
  matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi = {onsetFile2};
  matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = {regressorsFile2};
  matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress = struct('name', {}, 'val', {});
  matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond = struct('name', {}, 'onset', {}, 'duration', {});
  matlabbatch{1}.spm.stats.fmri_spec.sess(2).hpf = 125;

  opt.glm.concatenateRuns = false;
  newMatlabbatch = concatenateRuns(matlabbatch, opt);
  assertEqual(newMatlabbatch, matlabbatch);

  opt.glm.concatenateRuns = true;
  newMatlabbatch = concatenateRuns(matlabbatch, opt);

  fmri_spec = newMatlabbatch{1}.spm.stats.fmri_spec;

  assertEqual(numel(fmri_spec), 1);
  assertEqual(fmri_spec.sess.hpf, 125);
  assertEqual(size(fmri_spec.sess.scans{1}, 1), 84 * 2);

end
