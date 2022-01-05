% (C) Copyright 2021 CPP_SPM developers

clear;
clc;

run ../../initCppSpm.m;

%% --- parameters

subLabel = 'pilot001';

task = 'gratingBimodalMotion';

opt = high_res_get_option();

opt.verbosity = 2;

opt.space = 'individual';

%% --- run

use_schema = false;

raw = bids.layout(opt.dataDir, use_schema);

derivatives = bids.layout(opt.derivativesDir, use_schema);

events_files_destination = bids.query(derivatives, 'data', ...
                                      'task', task, ...
                                      'ses', '008', ...
                                      'modality', 'func');

events_files_destination = spm_fileparts(events_files_destination{1});

events_files = bids.query(raw, 'data', ...
                          'task', task, ...
                          'suffix', 'events', ...
                          'extension', '.tsv');

for i = 1:size(events_files, 1)

  [t_vaso, t_bold] = resample_events_tsv(events_files{i});

  p_vaso = struct( ...
                  'entities', struct('acq', 'vaso'), ...
                  'modality', 'func');

  p_bold = struct( ...
                  'entities', struct('acq', 'bold'), ...
                  'modality', 'func');

  [filename_vaso] = bids.create_filename(p_vaso, events_files{i});

  [filename_bold] = bids.create_filename(p_bold, events_files{i});

  bids.util.tsvwrite(fullfile(events_files_destination, filename_vaso), t_vaso);
  bids.util.tsvwrite(fullfile(events_files_destination, filename_bold), t_bold);

end

derivatives = bids.layout(opt.derivativesDir, use_schema);

resampled_events_files = bids.query(derivatives, 'data', ...
                                    'task', task, ...
                                    'suffix', 'events', ...
                                    'extension', '.tsv');

for i = 1:size(resampled_events_files, 1)

  events_mat_file = convertOnsetTsvToMat(opt, resampled_events_files{i});

end
