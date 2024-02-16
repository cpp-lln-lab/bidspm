% (C) Copyright 2023 bidspm developers

% Example to compute efficiency from
% https://www.nature.com/articles/s41598-024-52967-8
%
% Related to this thread:
% https://twitter.com/m_wall/status/1757311725777387739

clear;
clc;
close all;

addpath(fullfile(pwd, '..', '..'));
bidspm();

conditions = {'alcohol', 'neutral', 'negative', 'positive'};
for i = 1:numel(conditions)
  design_matrix{i} = ['trial_type.' conditions{i}];
end

%% create stats model JSON
bm = BidsModel();
NodeIdx = 1;

% high pass filter
bm.Nodes{NodeIdx}.Model.Options.HighPassFilterCutoffHz = 1 / 128;

for i = 1:numel(conditions)
  bm.Nodes{NodeIdx}.Model.X = design_matrix;
end

% contrast for each condition against baseline
bm.Nodes{NodeIdx}.DummyContrasts = struct('type', 't', ...
                                          'Contrasts', {design_matrix});

% contrast of interests
% alcohol > neural
% negative > neutral
% positive > neutral
conditions_to_check = {'alcohol', 'negative', 'positive'};
for i = 1:numel(conditions_to_check)
  contrast = struct('Test', 't', ...
                    'Name', [conditions_to_check{i} '_gt_neutral'], ...
                    'Weights', [1, -1], ...
                    'ConditionList', {{['trial_type.' conditions_to_check{i}], 'trial_type.neutral'}});
  bm.Nodes{NodeIdx}.Contrasts{i} = contrast;
end

bm.write('smdl.json');

%% create events TSV file
IBI = 25;
ISI = 0;
stimDuration = 4;
stimPerBlock = 40;
nbBlocks = 1;

TR = 1;

trial_type = {};
onset = [];
duration = [];

time = 0;

for iBlock = 1:nbBlocks
  for cdt = 1:numel(conditions)
    for iTrial = 1:stimPerBlock
      trial_type{end + 1} = conditions{cdt}; %#ok<*SAGROW>
      onset(end + 1) = time;
      duration(end + 1) = stimDuration;
      time = time + stimDuration + ISI;
    end
    time = time + IBI;
  end
end

tsv = struct('trial_type',  {trial_type}, 'onset', onset, 'duration', duration');

bids.util.tsvwrite('events.tsv', tsv);

opt.TR = TR;

opt.model.file = fullfile(pwd, 'smdl.json');

[e, X] = computeDesignEfficiency(fullfile(pwd, 'events.tsv'), opt);

%%
% saveas(gcf(), 'design_matrix.png');
% close(gcf());
%
% saveas(gcf(), 'events.png');
% close(gcf());
