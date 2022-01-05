clear;

%% --- parameters

% contrast = 'bold';
% repetition_time = 2.25;

contrast = 'vaso';
repetition_time = 1.6;

prefix = 'upsmpl_tempco_moco_';

nb_slices = 24;

opt = high_res_get_option();

input_dir = fullfile(pwd, 'inputs', 'raw');
output_dir = fullfile(opt.derivativesDir, 'sub-pilot001/ses-008/func');

stats_dir = fullfile(opt.derivativesDir, 'sub-pilot001', ['stats_submill_' contrast]);

opt.model.file = fullfile(pwd, 'model_smdl.json');

%% --- run

switch contrast

  case 'bold'

    events_files = spm_select('FPList', output_dir, '^sub.*acq-bold_run-.*_onsets.mat$');

  case 'vaso'

    events_files = spm_select('FPList', output_dir, '^sub.*acq-vaso_run-.*_onsets.mat$');

end

disp(events_files);

fmri_spec = defaultGlmBatch();

fmri_spec.dir = {stats_dir};
fmri_spec.timing.RT = repetition_time;
fmri_spec.timing.fmri_t = nb_slices;
fmri_spec.timing.fmri_t0 = nb_slices / 2;

% add info for each run
for i = 1:size(events_files, 1)
  confounds = spm_select('FPList', ...
                         output_dir, ...
                         ['^rp_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00' num2str(i) '_' contrast '.txt$']);

  % TODO
  % create realignement confounds that are upsampled or are a merge of those
  % of the bold and vaso realign:
  %
  % realignement happens for every second volume because we alternate vaso and
  % bold: but this gives rp_*.txt files with half the number of timepoints as
  % we have volumes in our time series after upsampling: SPM does not allow
  % that
  %
  confounds = '';

  switch contrast

    case 'bold'

      image = spm_select('FPList', ...
                         output_dir, ...
                         ['^' prefix 'sub-pilot001_ses-008_task-gratingBimodalMotion_run-00' num2str(i) '_' contrast '.nii$']);

    case 'vaso'

      image = spm_select('FPList', ...
                         output_dir, ...
                         ['^' prefix 'sub-pilot001_ses-008_task-gratingBimodalMotion_run-00' num2str(i) '_' contrast '_VASO_LN.nii$']);

  end

  fmri_spec.sess(i) = addRuntoBatch( ...
                                    image, ...
                                    events_files(i, :), ...
                                    confounds);
end

matlabbatch{1}.spm.stats.fmri_spec = fmri_spec;

matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0;

matlabbatch{end + 1}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{end}.spm.stats.fmri_est.spmmat = {fullfile(stats_dir, 'SPM.mat')};

save(fullfile(output_dir, 'glm_batch.mat'), 'matlabbatch');

spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

function sess = addRuntoBatch(image, events, confounds)
  sess = defaultGlmRunSubBatch();
  sess.scans = {image};
  sess.multi = cellstr(events);
  sess.multi_reg = cellstr(confounds);
end

function fmri_spec = defaultGlmBatch()

  fmri_spec.dir = {''};
  fmri_spec.timing.RT = nan;
  fmri_spec.timing.units = 'secs';
  fmri_spec.timing.fmri_t = 16;
  fmri_spec.timing.fmri_t0 = 8;
  fmri_spec.fact = struct('name', {}, 'levels', {});
  fmri_spec.bases.hrf.derivs = [0 0];
  fmri_spec.volt = 1;
  fmri_spec.global = 'None';
  fmri_spec.mask = {''};

end

function sess = defaultGlmRunSubBatch()

  sess.scans = {''};
  sess.regress = struct('name', {}, 'val', {});
  sess.cond = struct('name', {}, 'onset', {}, 'duration', {});
  sess.multi_reg = {''};

end
