function opt = getOption()
% returns a structure that contains the options chosen by the user to run
% slice timing correction, pre-processing, FFX, RFX.

if nargin<1
 opt = [];
end

% group of subjects to analyze
opt.groups = {''}; % {'blnd', 'ctrl'};
% suject to run in each group
opt.subjects = {1:3};  % {[1:2], [1:2]};


% task to analyze
% opt.taskName = 'motionDecoding';
opt.taskName = 'visMotion';


% The directory where the derivatives are located
% opt.dataDir = '/Users/mohamed/Desktop/MotionWorkshop/raw';
% opt.dataDir = '/Users/mohamed/Desktop/Data/raw';
opt.dataDir = '/home/remi/BIDS/visMotion/raw';


% Options for slice time correction
% If left unspecified the slice timing will be done using the mid-volume acquisition
% time point as reference.
% Slice order must be entered in time unit (ms) (this is the BIDS way of doing things)
% instead of the slice index of the reference slice (the "SPM" way of doing things).
% More info here: https://en.wikibooks.org/wiki/SPM/Slice_Timing
opt.sliceOrder = [];
opt.STC_referenceSlice = [];


% Options for normalize
% Voxel dimensions for resampling at normalization of functional data or leave empty [ ].
opt.funcVoxelDims = [];


% Suffix output directory for the saved jobs
opt.JOBS_dir = fullfile(opt.dataDir, '..', 'derivatives', 'SPM12_CPPL', 'JOBS', opt.taskName);

% specify the model file that contains the contrasts to compute
% opt.model.univariate.file = '/Users/mohamed/Documents/GitHub/BIDS_fMRI_scripts/model-motionDecodingUnivariate_smdl.json';
% opt.model.multivariate.file = '/Users/mohamed/Documents/GitHub/BIDS_fMRI_scripts/model-motionDecodingMultivariate_smdl.json';
opt.model.univariate.file = '/home/remi/github/CPP_BIDS_SPM_pipeline/model-visMotionLoc_smdl.json';


% Save the opt variable as a mat file to load directly in the preprocessing
% scripts
save('opt.mat','opt')

end
