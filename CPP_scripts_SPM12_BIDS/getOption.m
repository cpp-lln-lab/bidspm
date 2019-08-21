function opt = getOption()
% returns a structure that contains the options chosen by the user to run
% slice timing correction, pre-processing, FFX, RFX.

if nargin<1
    opt = [];
end

% group of subjects to analyze
opt.groups = {};    % {'blnd', 'ctrl'};
% suject to run in each group
opt.subjects = {};  % {[1:2], [1:2]};

% task to analyze
opt.taskName = '';

% The directory where the derivatives are located
opt.derivativesDir = '';

% Specify the number of dummies that you want to be removed.
opt.numDummies = 0;
opt.dummy_prefix = 'dr_';

% Options for slice time correction
opt.STC_referenceSlice = []; % reference slice: middle acquired slice (NOTE: Middle in time of acquisition, not space)
% If  slice order is entered in time unit (ms) doing  so,  the  next  item  (Reference Slice) will contain a reference time (in
% ms) instead of the slice index of the reference slice.
opt.STC_prefix = 'a';

% Options for realign/resliced
opt.realign_prefix = 'r';

% Options for normalize
opt.norm_prefix = 'w';
opt.funcVoxelDims = [];  % voxel dimensions to use for resampling at normalization

% suffix output directory for the saved jobs
opt.JOBS_dir = fullfile(opt.derivativesDir,'JOBS',opt.taskName);

%% SLICE TIMING INFORMATION
% TO BE USED ONLY IF SPM_BIDS CAN'T EXTRACT SLICE INFORMATION
opt.sliceOrder = [];

opt.funcVoxelDims = [];  % Voxel dimensions of the functional data or leave empty [ ]. 
% Save the opt variable as a mat file to load directly in the preprocessing
% scripts
save('opt.mat','opt')

end
