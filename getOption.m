function opt = getOption()
% returns a structure that contains the options chosen by the user to run
% slice timing correction, pre-processing, FFX, RFX.

if nargin<1
 opt = [];
end

% group of subjects to analyze
opt.groups = {''}; % {'blnd', 'ctrl'};
% suject to run in each group
opt.subjects = {[1:2]}; % {[1:2], [1:2]};

% task to analyze
opt.taskName = 'visMotion';

% The directory where the derivatives are located
opt.derivativesDir = '/Users/mohamed/Desktop/MotionWorkshop/derivatives';

% Specify the number of dummies that you want to be removed.
opt.numDummies = 0;
opt.dummyPrefix = 'dr_';

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
opt.JOBS_dir = fullfile(opt.derivativesDir, 'JOBS', opt.taskName);

opt.contrastList = {...
 {'VisMot'}; ...
 {'VisStat'}; ...
 % {'VisMot-VisStatic'}; ...
 };

% Save the opt variable as a mat file to load directly in the preprocessing
% scripts
save('opt.mat','opt')

end
