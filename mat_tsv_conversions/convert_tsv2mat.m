function convert_tsv2mat(tsv_file,TR)
%% This function takes a tsv file and converts it to an onset file suitable for SPM FFX analysis
% The scripts extracts the conditions' names, onsets, and durations (in seconds) from the tsv file,
% and converts them to TRs (time unit) by DIVIDING the onsets/durations by the TR.
% The ONSET MAT file is saved to be used by SPM for the FFX analysis
%%

% Read the tsv file
t = tdfread(tsv_file,'tab');
fprintf('reading the tsv file : %s \n', tsv_file)
conds = t.condition;        % assign all the tsv information to a variable called conds.

names_tmp=cell(size(conds,1),1);
for iCond = 1:size(conds,1)                        % for each line in the tsv file
    names_tmp(iCond,1)= cellstr(conds(iCond,:));   % Get the name of the condition
end

% Get the unique names of the conditions (removing repeitions)
names = unique(names_tmp)';
NumConditions =length(names);

% Create empty variables of onsets and durations
onsets = cell(1,NumConditions) ;
durations = cell(1,NumConditions) ;

% for each condition
for iCond = 1:NumConditions
    
    % Get the index of each condition by comparing the unique names and
    % each line in the tsv files
    idx(:,iCond) = find(strcmp(names(iCond),names_tmp)) ;
    onsets{1,iCond} = t.onset(idx(:,iCond))'./TR ;             % Get the onset and duration of each condition
    durations{1,iCond} = t.duration(idx(:,iCond))'./TR ;       % and divide them by the TR to get the time in TRs
    % rather than seconds
end

fprintf('TR : %.4f \n', TR)
fprintf('Onsets and durations divided by TR \n\n')

% save the onsets as a matfile
save(['Onsets_',tsv_file(1:end-4),'.mat'],'names','onsets','durations')


end