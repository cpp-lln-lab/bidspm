function opt = getOption()
% returns a structure that contains the options chosen by the user to run
% slice timing correction, pre-processing, FFX, RFX.

% TO DO
% - implement a way to only select some subjects from each group < -- Did we
% TEST this ????
% - create a function to check the options and set some defaults in case
% they are missing.
% - implement a way to give some specific names to each subject otherwise
% it will always start from '01' even if the user wants to skip X subjects
% that have alreay been processed
% - create a function that copies the raw data into a derivatives/SPM12-CPP
% directory (also make sure that the raw data is in read only mode)
% - make the name of the opt.mat different for each task ????

if nargin<1
    opt = [];
end

% group of subjects to analyze
opt.groups = {'con'};    % {'blnd', 'ctrl'};
% suject to run in each group
opt.subjects = {[1 2]};  % {[1:2], [1:2]};

% task to analyze
opt.taskName = 'decoding';

% The directory where the derivatives are located
opt.derivativesDir = '/Data/CrossMotBIDS/derivatives';

% Specify the number of dummies that you want to be removed.
opt.numDummies = 4;
opt.dummy_prefix = 'dr_';

% Options for slice time correction
opt.STC_referenceSlice = [2]; % reference slice: middle acquired slice (NOTE: Middle in time of acquisition, not space)
% If  slice order is entered in time unit (ms) doing  so,  the  next  item  (Reference Slice) will contain a reference time (in
% ms) instead of the slice index of the reference slice.
opt.STC_prefix = 'a';

% Options for realign/resliced
opt.realign_prefix = 'r';

% Options for normalize
opt.norm_prefix = 'w';

% suffix output directory for the saved jobs
opt.JOBS_dir = fullfile(opt.derivativesDir,'JOBS',opt.taskName);

%% SLICE TIMING INFORMATION
% TO BE USED ONLY IF SPM_BIDS CANT EXTRACT SLICE INFORMATION
opt.sliceOrder = [1:2:39 ,...
                  2:2:39];

% Save the opt variable as a mat file to load directly in the preprocessing
% scripts
save('opt.mat','opt')

end
