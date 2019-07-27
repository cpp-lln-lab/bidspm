function opt = getOption()

if nargin<1 
    opt = [];
end

% group of subjects to analyze
opt.groups = {'blnd', 'ctrl'};
% task to analyze
opt.taskName = 'olfid'; 
% The directory where the derivatives are located
opt.derivativesDir = 'D:\BIDS\olf_blind';

% Specify the number of dummies that you want to be removed.
opt.numDummies = 4;


end