clear
clc
close all

FWHM_1 = 6;

URL = 'http://www.fil.ion.ucl.ac.uk/spm/download/data/MoAEpilot/MoAEpilot.bids.zip';

WD = pwd; % the directory with this script becomes the current directory
addpath(genpath(WD)) % we add all the subfunctions that are in the sub directories

opt = getOption();

% respecify options here in case the getOption file has been modified on
% the repository
opt.derivativesDir = fullfile(WD, '..', 'MoAE_pilot_output');
opt.groups = {''}; % no specific group
opt.subjects = {1};  % first subject
opt.taskName = 'auditory'; % task to analyze
opt.contrastList = {...
    {'listening'} ...
    };

% the following options are less important but are added to reset all
% options
opt.numDummies = 0;
opt.STC_referenceSlice = [];
opt.sliceOrder = [];
opt.funcVoxelDims = [];
opt.JOBS_dir = fullfile(opt.derivativesDir, 'JOBS', opt.taskName);


%% Get data
if ~exist(opt.derivativesDir, 'dir')
    [~,~,~] = mkdir(opt.derivativesDir);
end
fprintf('%-40s:', 'Downloading dataset...');
urlwrite(URL, 'MoAEpilot.zip');
unpack('MoAEpilot.zip', opt.derivativesDir);


%% Check dependencies
% If toolboxes are not in the MATLAB Directory and needed to be added to
% the path

% In case some toolboxes need to be added the matlab path, specify and uncomment 
% in the lines below

% toolbox_path = '';
% addpath(fullfile(toolbox_path)

checkDependencies();


%% Run batches
BIDS_rmDummies(opt);
BIDS_STC(opt);
BIDS_SpatialPrepro(opt);
BIDS_Smoothing(FWHM_1, opt);
BIDS_FFX(1, FWHM_1, opt);
BIDS_FFX(2, FWHM_1, opt);

