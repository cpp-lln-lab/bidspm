% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function bidsSmoothing(funcFWHM, opt)
    % This scripts performs smoothing to the functional data using a full width
    % half maximum smoothing kernel of size "mm_smoothing".

    % if input has no opt, load the opt.mat file
    if nargin < 2
        opt = [];
    end
    opt = loadAndCheckOptions(opt);

    % load the subjects/Groups information and the task name
    [group, opt, BIDS] = getData(opt);

    %% Loop through the groups, subjects, and sessions
    for iGroup = 1:length(group)

        groupName = group(iGroup).name;

        for iSub = 1:group(iGroup).numSub

            subID = group(iGroup).subNumber{iSub};

            printProcessingSubject(groupName, iSub, subID);

            fprintf(1, 'PREPARING: SMOOTHING JOB \n');

            matlabbatch = setBatchSmoothing(BIDS, opt, subID, funcFWHM);

            saveMatlabBatch(matlabbatch, ['smoothing_FWHM-' num2str(funcFWHM)], opt, subID);

            spm_jobman('run', matlabbatch);

        end
    end

end
