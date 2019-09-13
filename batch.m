%% Run batches
WD = pwd;
addpath(genpath(WD))
toolbox_path = '/home/remi/Dropbox';
addpath(fullfile(toolbox_path, 'Code', 'MATLAB', 'Neuroimaging', 'NiftiTools'))

opt = getOption();
checkDependencies();


% BIDS_rmDummies(opt);
% BIDS_STC(opt);
% BIDS_SpatialPrepro(opt);
% BIDS_Smoothing(6, opt);
BIDS_FFX(1, 6, opt);
% cd(WD); BIDS_FFX(2, 6, opt);
% cd(WD); BIDS_RFX(1, 6, 6)
% cd(WD); BIDS_RFX(2, 6, 6)

cd(WD)