%% Run batches
opt = getOption();

WD = fullfile(pwd,'subfun');
addpath(genpath(WD))
toolbox_path = '/home/remi/Dropbox';
addpath(fullfile(toolbox_path, 'Code', 'MATLAB', 'Neuroimaging', 'NiftiTools'))

%cd(WD); checkDependencies();
%cd(WD); BIDS_rmDummies(opt);
%cd(WD); BIDS_STC(opt);
%cd(WD); BIDS_SpatialPrepro(opt);
%cd(WD); BIDS_Smoothing(6, opt);
%cd(WD); BIDS_FFX(1, 6, opt);
%cd(WD); BIDS_FFX(2, 6, opt);
%cd(WD); BIDS_RFX(1, 6, 6)
%cd(WD); BIDS_RFX(2, 6, 6)
