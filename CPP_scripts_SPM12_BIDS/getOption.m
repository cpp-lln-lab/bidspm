function opt = getOption()

% TO DO
% implement a way to only select some subjects from each group

if nargin<1
    opt = [];
end

% group of subjects to analyze
opt.groups = {'con'};    % {'blnd', 'ctrl'};
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
