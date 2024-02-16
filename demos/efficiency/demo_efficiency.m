% (C) Copyright 2023 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

%% create stats model JSON
bm = BidsModel();
NodeIdx = 1;
bm.Nodes{NodeIdx}.Model.X = {'trial_type.cdt_A', 'trial_type.cdt_B'};
bm.Nodes{NodeIdx}.DummyContrasts = struct('type', 't', ...
                                          'Contrasts', {{'trial_type.cdt_A', 'trial_type.cdt_B'}});

contrast = struct('type', 't', ...
                  'Name', 'A_gt_B', ...
                  'Weights', [1, -1], ...
                  'ConditionList', {{'trial_type.cdt_A', 'trial_type.cdt_B'}});

bm.Nodes{NodeIdx}.Contrasts{1} = contrast;

bm.write('smdl.json');

%% create events TSV file
conditions = {'cdt_A', 'cdt_B'};
IBI = 5;
ISI = 0.1;
stimDuration = 1.5;
stimPerBlock = 12;
nbBlocks = 10;

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

opt.TR = 2;

opt.model.file = fullfile(pwd, 'smdl.json');

e = computeDesignEfficiency(fullfile(pwd, 'events.tsv'), opt);
