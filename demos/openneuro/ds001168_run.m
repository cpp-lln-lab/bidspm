% (C) Copyright 2020 CPP_SPM developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm();

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds001168');
output_dir = fullfile(root_dir, 'outputs', 'ds001168', 'derivatives');

opt.bidsFilterFile.t1w.ses = '1';
opt.bidsFilterFile.bold.acq = 'fullbrain';

opt.query.modality = {'anat', 'func', 'fmap'};

%% Preprocessing

cpp_spm(bids_dir, output_dir, 'subject', ...
        'participant_label', {'01'}, ...
        'action', 'preprocess', ...
        'task', {'rest'}, ...
        'space', {'IXI549Space'}, ...
        'options', opt);

% Not implemented yet
% bidsFFX('specifyAndEstimate', opt);
% bidsFFX('contrasts', opt);
% bidsResults(opt);
