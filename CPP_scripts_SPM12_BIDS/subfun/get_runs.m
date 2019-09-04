function [runs, numRuns] = get_runs(BIDS, subID, session, opt)
% for a given BIDS data set, subject identity, session and options this returns the
% name of the runs and their number
%
% INPUTS
% BIDS - variable returned by spm_BIDS when exploring a BIDS data set
% subID - ID of the subject ; in BIDS lingo that means that for a file name
% sub-02_task-foo_bold.nii the subID will be the string '02'
% session - ID of the session of interes ; in BIDS lingo that means that for a file name
% sub-02_ses-pretest_task-foo_bold.nii the sesssion will be the string 'pretest'
% opt - options structure defined by the getOption function. Mostly used to find the
% task name.

% TO CHECK
% what happens if several subID/sessions are given as input (as a cell of strings)?

runs = spm_BIDS(BIDS, 'runs', ...
    'sub', subID, ...
    'task', opt.taskName, ...
    'ses', session, ...
    'type', 'bold');
numRuns = size(runs,2);     % Get the number of runs

if numRuns==0
    numRuns = 1;
    runs = {''};
end

end