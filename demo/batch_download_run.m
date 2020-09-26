% (C) Copyright 2019 Remi Gau

% This script will download the dataset from the FIL for the block design SPM
% tutorial and will run the basic preprocessing, FFX and contrasts on it.
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline (e.g use of FAST
% instead of AR(1), motion regressors added)

clear;
clc;

% Smoothing to apply
FWHM = 6;

% URL of the data set to download
URL = 'http://www.fil.ion.ucl.ac.uk/spm/download/data/MoAEpilot/MoAEpilot.bids.zip';

% directory with this script becomes the current directory
WD = fileparts(mfilename('fullpath'));

% we add all the subfunctions that are in the sub directories
addpath(fullfile(WD, '..'));
addpath(genpath(fullfile(WD, '..', 'src')));
addpath(genpath(fullfile(WD, '..', 'lib')));

%% Set options
opt = getOption();

% respecify options here in case the getOption file has been modified on
% the repository

% the dataset will downloaded and analysed there
opt.dataDir = fullfile(WD, 'output', 'MoAEpilot');
opt.groups = {''}; % no specific group
opt.subjects = {[]};  % first subject
opt.taskName = 'auditory'; % task to analyze

% the following options are less important but are added to reset all
% options
opt.STC_referenceSlice = [];
opt.sliceOrder = [];
opt.funcVoxelDims = [];
opt.jobsDir = fullfile(opt.dataDir, '..', 'derivatives', 'SPM12_CPPL', 'JOBS', opt.taskName);

% specify the model file that contains the contrasts to compute
opt = rmfield(opt, 'model');
opt.model.univariate.file = fullfile(WD, 'model-MoAE_smdl.json');

% specify the result to compute
opt.result.Steps(1) = struct( ...
                             'Level',  'subject', ...
                             'Contrasts', struct( ...
                                                 'Name', 'listening', ... % has to match
                                                 'Mask', false, ...
                                                 'MC', 'FWE', ... FWE, none, FDR
                                                 'p', 0.05, ...
                                                 'k', 0, ...
                                                 'NIDM', true));

opt.result.Steps(1).Contrasts(2) = struct( ...
                                          'Name', 'listening_inf_baseline', ...
                                          'Mask', false, ...
                                          'MC', 'none', ... FWE, none, FDR
                                          'p', 0.01, ...
                                          'k', 0, ...
                                          'NIDM', true);

%% Get data
% fprintf('%-40s:', 'Downloading dataset...');
% urlwrite(URL, 'MoAEpilot.zip');
% unzip('MoAEpilot.zip', fullfile(WD, 'output'));

%% Check dependencies
% If toolboxes are not in the MATLAB Directory and needed to be added to
% the path

% In case some toolboxes need to be added the matlab path, specify and uncomment
% in the lines below

% toolbox_path = '';
% addpath(fullfile(toolbox_path)

checkDependencies();

%% Run batches
isMVPA = 0;

% bidsCopyRawFolder(opt, 1);
bidsSTC(opt);
bidsSpatialPrepro(opt);
bidsSmoothing(FWHM, opt);
bidsFFX('specifyAndEstimate', opt, FWHM, isMVPA);
bidsFFX('contrasts', opt, FWHM, isMVPA);
bidsResults(opt, FWHM, [], isMVPA);
