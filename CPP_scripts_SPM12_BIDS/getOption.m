function opt = getOption()

% TO DO
% implement a way to only select some subjects from each group

if nargin<1 
    opt = [];
end

% group of subjects to analyze
opt.groups = {'blnd', 'ctrl'};
opt.subjects = {[1:3]};
% task to analyze
opt.taskName = 'olfid'; 
% The directory where the derivatives are located
opt.derivativesDir = 'D:\BIDS\olf_blind';

% Specify the number of dummies that you want to be removed.
opt.numDummies = 4;
opt.dummy_prefix = 'dr_';

% Options for slice time correction
opt.STC_referenceSlice = []; % reference slice: middle acquired slice (NOTE: Middle in time of acquisition, not space)
% If  slice order is entered in time unit (ms) doing  so,  the  next  item  (Reference Slice) will contain a reference time (in
% ms) instead of the slice index of the reference slice.
opt.STC_prefix = 'a';

% suffix output directory for the saved jobs
opt.JOBS_dir = fullfile('JOBS',opt.taskName);

end