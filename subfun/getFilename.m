function fileName = getFilename(BIDS, subNumber, session, run, type, opt)
% for a given BIDS data set, subject identity, session, runs and options 
% this returns the name of the file for that run.
%
% INPUTS
% BIDS - variable returned by spm_BIDS when exploring a BIDS data set
% subID - ID of the subject ; in BIDS lingo that means that for a file name
% sub-02_task-foo_bold.nii the subID will be the string '02'
% session - ID of the session of interes ; in BIDS lingo that means that for a file name
% sub-02_ses-pretest_task-foo_bold.nii the sesssion will be the string 'pretest'
% run - ID of the run of interes
% type - string ; modality type to look for. For example: 'bold', 'events',
% 'stim', 'physio'...
% opt - options structure defined by the getOption function. Mostly used to find the
% task name.

% TO CHECK
% what happens if several subID/sessions/runs are given as input (as a cell of strings)?

fileName = spm_BIDS(BIDS, 'data', ...
    'sub', subNumber, ...
    'run', run, ...
    'ses', session, ...
    'task', opt.taskName, ...
    'type', type);

end