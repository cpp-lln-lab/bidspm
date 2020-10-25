% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function bidsCreateVDM(opt)
    % bidsCreateVDM(opt)
    %
    % adapted from spmup spmup_BIDS_preprocess (@ commit
    % 198c980d6d7520b1a996f0e56269e2ceab72cc83)
    
    if nargin < 1
        opt = [];
    end
    opt = loadAndCheckOptions(opt);
    
    % load the subjects/Groups information and the task name
    [group, opt, BIDS] = getData(opt);
    
    fprintf(1, ' FIELDMAP WORKFLOW\n');
    
    %% Loop through the groups, subjects, and sessions
    for iGroup = 1:length(group)
        
        groupName = group(iGroup).name;
        
        for iSub = 1:group(iGroup).numSub
            
            subID = group(iGroup).subNumber{iSub};
            
            types = spm_BIDS(BIDS, 'types', 'sub', subID);
            
            if any(ismember(types, {'phase12', 'phasediff', 'fieldmap', 'epi'}))
                
                printProcessingSubject(groupName, iSub, subID);
                
                fprintf(1, ' FIELDMAP WORKFLOW: COREGISTERING FIELD MAPS TO FIRST FUNC IMAGE\n');
                
                matlabbatch = setBatchCoregistrationFmap(opt, BIDS, subID);
                
                %             saveMatlabBatch(matlabbatch, 'coregister_fmap', opt, subID);
                
                %             spm_jobman('run', matlabbatch);
                
                %             fprintf(1, ' FIELDMAP WORKFLOW: CREATING VDMs \n');
                
            end
            
        end
        
    end
end
