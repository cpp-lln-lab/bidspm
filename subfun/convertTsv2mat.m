function convertTsv2mat(tsvFile)
%% This function takes a tsv file and converts it to an onset file suitable for SPM ffx analysis
% The scripts extracts the conditions' names, onsets, and durations, and
% converts them to TRs (time unit) and saves the onset file to be used for
% SPM
%%

% Read the tsv file
t = spm_load(tsvFile);
fprintf('reading the tsv file : %s \n', tsvFile)

if ~isfield(t, 'trial_type')
    
    error('There was no trial_type field in the following file \n %s', tsvFile)
    
end

conds = t.trial_type;        % assign all the tsv information to a variable called conds.

% Get the unique names of the conditions (removing repetitions)
names = unique(conds);
numConditions =length(names);

% Create empty variables of onsets and durations
onsets = cell(1,numConditions) ;
durations = cell(1,numConditions) ;

% for each condition
for iCond = 1:numConditions

    % Get the index of each condition by comparing the unique names and
    % each line in the tsv files
    idx{iCond,1} = find(strcmp(names(iCond), conds)) ;
    onsets{1,iCond} = t.onset(idx{iCond,1})' ;             % Get the onset and duration of each condition
    durations{1,iCond} = t.duration(idx{iCond,1})' ;
    
end

% save the onsets as a matfile
[path, file] = spm_fileparts(tsvFile);
save(fullfile(path, ['Onsets_' file '.mat']), ...
    'names','onsets','durations')


end
