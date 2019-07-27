function [group, opt, BIDS] = getData(opt)
% The following structure will be the base that the scripts will use to run
% the preprocessing pipeline according to the BIDS Structure

% The directory where the derivatives are located
derivativesDir = opt.derivativesDir;

BIDS = spm_BIDS(derivativesDir);

subjects = spm_BIDS(BIDS, 'subjects');

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