clear
clc
close all

addToolboxs2Path = 1 ;
FWHM_1 = 6;

URL = 'http://www.fil.ion.ucl.ac.uk/spm/download/data/MoAEpilot/MoAEpilot.bids.zip';

WD = pwd;
addpath(genpath(WD))

opt = getOption();

opt.derivativesDir = fullfile(WD, 'MoAEpilot');
opt.groups = {''}; % no specific group
opt.subjects = {1};  % subject one
opt.taskName = 'auditory'; % task to analyze
opt.numDummies = 0;
opt.contrastList = {...
    {'listening'} ...
    };


%% Get data
if ~exist(opt.derivativesDir, 'dir')
    [~,~,~] = mkdir(opt.derivativesDir);
end
fprintf('%-40s:', 'Downloading dataset...');
urlwrite(URL, 'MoAEpilot.zip');
unpack('MoAEpilot.zip', WD);


%% Check dependencies
% If toolboxes are not in the MATLAB Directory and needed to be added to
% the path

% In case some toolboxes need to be added the matlab path, specify and uncomment 
% in the lines below

% if addToolboxs2Path
%     toolbox_path = '';
%     addpath(fullfile(toolbox_path)
% end

checkDependencies();


%% Run batches
BIDS_rmDummies(opt);
BIDS_STC(opt);
BIDS_SpatialPrepro(opt);
BIDS_Smoothing(FWHM_1, opt);
BIDS_FFX(1, FWHM_1, opt);
BIDS_FFX(2, FWHM_1, opt);

cd(WD)
