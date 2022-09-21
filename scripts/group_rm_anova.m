% attempt at a full factorial design
%
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initEnv.m;

% in participants.tsv
group_field = 'Group';

opt = opt_stats_group_level();

opt = checkOptions(opt);

opt.verbosity = 2;

opt.pipeline.type = 'stats';

opt.model.bm = BidsModel('file', opt.model.file);

opt.space = opt.model.bm.Input.space;
opt.taskName = opt.model.bm.Input.task;

[BIDS, opt] = getData(opt, opt.dir.preproc);

% for folder naming
node_name = 'rm_anova';
contrasts = 'ALL';
groups = 'ALL';

% Levels names for each factor
group_labels = unique(BIDS.raw.participants.content.(group_field));
task_labels = opt.taskName;
odor_labels = {'almond', 'eucalyptus'};
side_labels = {'left', 'right'};
subject_labels = opt.subjects;

% list of constrasts and the levels they correspond to
contrasts_list = {'olfid_almond_left'; ...
                  'olfid_almond_right'; ...
                  'olfid_eucalyptus_left'; ...
                  'olfid_eucalyptus_right'; ...
                  'olfloc_almond_left'; ...
                  'olfloc_almond_right'; ...
                  'olfloc_eucalyptus_left'; ...
                  'olfloc_eucalyptus_right'};

contrast_levels = cartesian(1:numel(task_labels), ...
                            1:numel(odor_labels), ...
                            1:numel(side_labels));

%%
opt.dir.output = fullfile(opt.dir.stats, 'derivatives', 'bidspm-groupStats');
opt.dir.jobs = fullfile(opt.dir.output, 'jobs',  strjoin(opt.taskName, ''));

% collect con images
for iSub = 1:numel(subject_labels)
  sub_label = subject_labels{iSub};
  contrasts_images_filenames{iSub} = findSubjectConImage(opt, ...
                                                         sub_label, ...
                                                         contrasts_list); %#ok<SAGROW>
end

%% set batch
factor = @(w, x, y, z) struct('name', w, ...
                              'levels', x, ...
                              'dept', y, ...
                              'variance', 1, ...
                              'gmsca', 0, ...
                              'ancova', 0);

factorial_design.des.fd.fact(1) = factor('group', numel(group_labels), false);
factorial_design.des.fd.fact(end + 1) = factor('task', numel(task_labels), true);
factorial_design.des.fd.fact(end + 1) = factor('odor', numel(odor_labels), true);
factorial_design.des.fd.fact(end + 1) = factor('side', numel(side_labels), true);
factorial_design.des.fd.fact(end + 1) = factor('subject', numel(subject_labels), false);

factorial_design.dir = {getRFXdir(opt, node_name, contrasts, groups)};

row = 1;

for iSub = 1:numel(subject_labels)

  sub_label = opt.subjects{iSub};

  sub_idx = strcmp(BIDS.raw.participants.content.participant_id, ['sub-' sub_label]);
  participant_group = BIDS.raw.participants.content.(group_field){sub_idx};

  group_index = ismember(participant_group, group_labels);

  for iCon = 1:numel(contrasts_list)
    icell = struct('levels', [group_index contrast_levels(iCon, :) iSub], ...
                   'scans', {contrasts_images_filenames{iSub}(iCon)});
    factorial_design.des.fd.icell(row) = icell;
    row = row + 1;
  end

end

factorial_design.des.fd.contrasts = 1;

factorial_design.cov = struct('c', {}, ...
                              'cname', {}, ...
                              'iCFI', {}, ...
                              'iCC', {});
factorial_design.multi_cov = struct('files', {}, ...
                                    'iCFI', {}, ...
                                    'iCC', {});

factorial_design.masking.tm.tm_none = 1;
factorial_design.masking.im = 1;
factorial_design.masking.em = {''};

factorial_design.globalc.g_omit = 1;

factorial_design.globalm.gmsca.gmsca_no = 1;
factorial_design.globalm.glonorm = 1;

matlabbatch{1}.spm.stats.factorial_design = factorial_design;

matlabbatch = setBatchEstimateModel(matlabbatch, ...
                                    opt, ...
                                    node_name, ...
                                    contrasts, ...
                                    groups);

%% run

saveAndRunWorkflow(matlabbatch, 'RM ANOVA', opt);
