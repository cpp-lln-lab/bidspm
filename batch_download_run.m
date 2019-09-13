% TO DO
% - make the name of the opt.mat different for each task ????
% - add a check to make sure that dummies are not removed AGAIN if this has
% already been done


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
opt.groups = {''};    % {'blnd', 'ctrl'};
opt.subjects = {1};  % {[1:2], [1:2]};
opt.taskName = 'auditory'; % task to analyze


%% Get data
if ~exist(opt.derivativesDir, 'dir')
    [~,~,~] = mkdir(opt.derivativesDir);
end
fprintf('%-40s:', 'Downloading dataset...');
urlwrite(URL, 'MoAEpilot.zip');
unzip('MoAEpilot.zip', WD);


%% Check dependencies
% If toolboxes are not in the MATLAB Directory and needed to be added to
% the path
if addToolboxs2Path
    toolbox_path = '/home/remi/Dropbox';
    addpath(fullfile(toolbox_path, 'Code', 'MATLAB', 'Neuroimaging', 'NiftiTools'))
    addpath(fullfile(toolbox_path, 'Code', 'MATLAB', 'Neuroimaging', 'SPM', 'spm12'))
end
checkDependencies();


%% Run batches
BIDS_rmDummies(opt);
BIDS_STC(opt);
% BIDS_SpatialPrepro(opt);
% BIDS_Smoothing(FWHM_1, opt);
% BIDS_FFX(1, FWHM_1, opt);
% BIDS_FFX(2, FWHM_1, opt);

cd(WD)
