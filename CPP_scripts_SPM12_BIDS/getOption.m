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


end