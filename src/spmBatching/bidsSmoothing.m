function bidsSmoothing(funcFWHM, opt)
    % This scripts performs smoothing to the functional data using a full width
    % half maximum smoothing kernel of size "mm_smoothing".

    % if input has no opt, load the opt.mat file
    if nargin < 2
        load('opt.mat');
        fprintf('opt.mat file loaded \n\n');
    end

    % load the subjects/Groups information and the task name
    [group, opt, BIDS] = getData(opt);

    %% Loop through the groups, subjects, and sessions
    for iGroup = 1:length(group)

        groupName = group(iGroup).name;

        for iSub = 1:group(iGroup).numSub

            subID = group(iGroup).subNumber{iSub};

            fprintf(1, 'PREPARING: SMOOTHING JOB \n');

            matlabbatch = setBatchSmoothing(BIDS, subID, opt, funcFWHM, groupName);

            saveMatlabBatch(matlabbatch, 'Smoothing', opt, subID);

            spm_jobman('run', matlabbatch);

        end
    end

end
