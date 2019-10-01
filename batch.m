%% Run batches
opt = getOption();

% the cdirectory with this script becomes the current directory
WD = pwd;

% we add all the subfunctions that are in the sub directories
addpath(genpath(WD))

% In case some toolboxes need to be added the matlab path, specify and uncomment 
% in the lines below
% toolbox_path = '';
% addpath(fullfile(toolbox_path)

checkDependencies();

BIDS_rmDummies(opt);
BIDS_STC(opt);
BIDS_SpatialPrepro(opt);
BIDS_Smoothing(6, opt);
BIDS_FFX(1, 6, opt);
BIDS_FFX(2, 6, opt);

%cd(WD); BIDS_RFX(1, 6, 6)
%cd(WD); BIDS_RFX(2, 6, 6)
