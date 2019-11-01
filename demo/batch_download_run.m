% This script will download the dataset from the FIL for the block design SPM  
% tutorial and will run the basic preprocessing, FFX and contrasts on it.
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline (e.g use of FAST
% instead of AR(1), motion regressors added)

clear
clc
close all

% Smoothing to apply
FWHM = 6;

% URL of the data set to download
URL = 'http://www.fil.ion.ucl.ac.uk/spm/download/data/MoAEpilot/MoAEpilot.bids.zip';

% directory with this script becomes the current directory
WD = fileparts(mfilename('fullpath')); 

% we add all the subfunctions that are in the sub directories
addpath(genpath(fullfile(WD, '..'))) 


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
opt.JOBS_dir = fullfile(opt.dataDir, '..', 'derivatives', 'SPM12_CPPL', 'JOBS', opt.taskName);


% specify the model file that contains the contrasts to compute
opt = rmfield(opt, 'model');
opt.model.univariate.file = fullfile(WD, 'demo', 'model-MoAE_smdl.json');


%% Get data
fprintf('%-40s:', 'Downloading dataset...');
urlwrite(URL, 'MoAEpilot.zip');
unzip('MoAEpilot.zip', fullfile(WD, 'output'));


%% Check dependencies
% If toolboxes are not in the MATLAB Directory and needed to be added to
% the path

% In case some toolboxes need to be added the matlab path, specify and uncomment 
% in the lines below

% toolbox_path = '';
% addpath(fullfile(toolbox_path)

checkDependencies();


%% Run batches
BIDS_copyRawFolder(opt, 1)
BIDS_STC(opt);
BIDS_SpatialPrepro(opt);
BIDS_Smoothing(FWHM, opt);
BIDS_FFX(1, FWHM, opt, 0);
BIDS_FFX(2, FWHM, opt, 0);


