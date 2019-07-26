function convert_mat2tsv(mat_file,TR)
%% This function takes an SPM ONSET MAT file and converts it to a tab-seperated (TSV) file
% The scripts extracts the conditions' names, onsets, and durations.
% The scripts takes the onsets and durations (in TR units) and converts
% them to seconds by MULTIPLYING the onsets/durations by the TR.
%%
% Read the mat file
    load(mat_file);

    % Get the number of unique conditions
    numConditions = length(onsets);
    
% create temporary variables for names/onsets/durations
    names_tmp = [];
    onsets_tmp = [];
    durations_tmp = [];
    
  % For each condition
  for iCond=1:numConditions
      names_tmp = [names_tmp ; repmat(names(iCond),length(durations{iCond}),1)] ; % add the condition names
      onsets_tmp= [onsets_tmp; onsets{iCond}'];                 % add all onsets
      durations_tmp= [durations_tmp; durations{iCond}'];        % add all Durations
  end

% clear the variables names/onsets/durations
clear names onsets durations

names = names_tmp ;
onsets = onsets_tmp ;
durations = durations_tmp ;

% Convert from TRs to seconds
onsets = onsets*TR;         % Multiply the onsets (in TR) to seconds
durations=durations*TR;     % Multiply the durations (in TR) to seconds

% Sort the onsets so we have the tsv in the right chronological order
[~,I] = sort(onsets);

% Create a table 
t=table(onsets(I),durations(I),names(I),'VariableNames',{'onset','duration','condition'});

% Export the table as csv and convert it to a tsv
writetable(t,[matfile(1:end-4),'.csv'],'Delimiter','tab');
movefile([matfile(1:end-4),'.csv'],[matfile(1:end-4),'.tsv'])


end
