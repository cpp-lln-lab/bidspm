function [group, opt, BIDS] = getData(opt)
% The following structure will be the base that the scripts will use to run
% the preprocessing pipeline according to the BIDS Structure

fprintf(1,'FOR TASK: %s\n', opt.taskName)

% The directory where the derivatives are located
derivativesDir = opt.derivativesDir;

BIDS = spm_BIDS(derivativesDir);

% get IDs of all subjects
subjects = spm_BIDS(BIDS, 'subjects');

% get metadata for bold runs for that task 
% we take those from the first run of the first subject assuming it can
% apply to all others.
metadata = spm_BIDS(BIDS, 'metadata', ...
    'task', opt.taskName, ...
    'sub', subjects{1}, ...
    'type', 'bold');
opt.metadata = metadata{1};

% Add the different groups in your experiment
%% GROUP 1
for iGroup = 1:numel(opt.groups)
    group(iGroup).name = opt.groups{iGroup};                            % NAME OF THE GROUP %#ok<*AGROW>
    
    idx = strfind(subjects, group(iGroup).name);
    idx = find(cell2mat(idx));
    group(iGroup).subNumber = subjects(idx);                            % SUBJECT ID .. con01 , con02 , etc.
    group(iGroup).numSub = length(group(1).subNumber) ;                 % Number of subjects in the group
end


end