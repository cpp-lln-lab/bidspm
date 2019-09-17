function [sessions, numSessions] = getSessions(BIDS, subID, opt)
% for a given BIDS data set, subject identity and options this returns the
% name of the sessions and their number
%
% INPUTS
% BIDS - variable returned by spm_BIDS when exploring a BIDS data set
% subID - ID of the subject ; in BIDS lingo that means that for a file name
% sub-02_task-foo_bold.nii the subID will be the string '02'
% opt - options structure defined by the getOption function. Mostly used to find the
% task name.

% TO CHECK
% what happens if several subID are given as input?

sessions = spm_BIDS(BIDS, 'sessions', ...
    'sub', subID, ...
    'task', opt.taskName);
numSessions = size(sessions,2);
if numSessions==0
    numSessions = 1;
    sessions = {''};
end
            
end