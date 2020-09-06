function bidsSTC(opt)
    % Performs SLICE TIMING CORRECTION of the functional data. The
    % script for each subject and can handle multiple sessions and multiple
    % runs.
    %
    % Slice timing units is in milliseconds to be BIDS compliant and not in slice number
    % as is more traditionally the case with SPM.
    %
    % In the case the slice timing information was not specified in the json FILES
    % in the BIDS data set (e.g it couldnt be extracted from the trento old scanner),
    % then add this information manually in opt.sliceOrder field.
    %
    % If this is empty the slice timing correction will not be performed
    %
    % If not specified this function will take the mid-volume time point as reference
    % to do the slice timing correction
    %
    % See README.md for more information about slice timing correction
    %
    % INPUT:
    % opt - options structure defined by the getOption function. If no inout is given
    % this function will attempt to load a opt.mat file in the same directory
    % to try to get some options

    % if input has no opt, load the opt.mat file
    if nargin < 1
        load('opt.mat');
        fprintf('opt.mat file loaded \n\n');
    end

    % load the subjects/Groups information and the task name
    [group, opt, BIDS] = getData(opt);

    fprintf(1, 'DOING SLICE TIME CORRECTION\n');

    %% Loop through the groups, subjects, and sessions
    for iGroup = 1:length(group)

        groupName = group(iGroup).name;

        for iSub = 1:group(iGroup).numSub

            % Get the ID of the subject
            % (i.e SubNumber doesnt have to match the iSub if one subject is exluded)
            subID = group(iGroup).subNumber{iSub};

            printProcessingSubject(groupName, iSub, subID);

            %% GET FUNCTIOVAL FILES
            fprintf(1, ' BUILDING STC JOB : STC\n');

            matlabbatch = setBatchSTC(BIDS, opt, subID);

            % The following lines are commented out because those parameters
            % can be set in the spm_my_defaults.m
            % matlabbatch{1}.spm.temporal.st.prefix = spm_get_defaults('slicetiming.prefix');

            if ~isempty(matlabbatch)
                saveMatlabBatch(matlabbatch, 'STC', opt, subID);

                spm_jobman('run', matlabbatch);
            end

        end
    end

end
