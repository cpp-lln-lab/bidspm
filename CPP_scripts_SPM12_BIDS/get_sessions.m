function [sessions, numSessions] = get_sessions(BIDS, subNumber, opt)

sessions = spm_BIDS(BIDS, 'sessions', ...
    'sub', subNumber, ...
    'task', opt.taskName);
numSessions = size(sessions,2);
if numSessions==0
    numSessions = 1;
    sessions = {''};
end
            
end