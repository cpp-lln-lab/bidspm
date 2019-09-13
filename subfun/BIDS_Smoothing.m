function BIDS_Smoothing(mmSmoothing,opt)
% This scripts performs smoothing to the functional data using a full width
% half maximum smoothing kernel of size "mm_smoothing".


% if input has no opt, load the opt.mat file
if nargin<2
    load('opt.mat')
    fprintf('opt.mat file loaded \n\n')
end

% load the subjects/Groups information and the task name
[group, opt, BIDS] = getData(opt);

% creates prefix to look for
prefix = getPrefix('smoothing',opt);


%% Loop through the groups, subjects, and sessions
for iGroup= 1:length(group)              % For each group
    groupName = group(iGroup).name ;     % Get the Group name

    for iSub = 1:group(iGroup).numSub    % For each subject in the group
        subNumber = group(iGroup).subNumber{iSub}; % Get the Subject ID
        fprintf(1,'PREPARING: SMOOTHING JOB \n')

        sesCounter = 1;                 % file/loop counter

        % identify sessions for this subject
        [sessions, numSessions] = getSessions(BIDS, subNumber, opt);

        % clear previous matlabbatch and files
        matlabbatch = [];
        allFiles=[];

        for iSes = 1:numSessions        % For each session

            % get all runs for that subject across all sessions
            [runs, numRuns] = getRuns(BIDS, subNumber, sessions{iSes}, opt);

            %numRuns = group(iGroup).numRuns(iSub);
            for iRun = 1:numRuns                     % For each run
                fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s SESSION: %i RUN:  %i \n',...
                    groupName,iSub,subNumber,iSes,iRun)

                % get the filename for this bold run for this task
                [fileName, subFuncDataDir]= getBoldFilename(...
                    BIDS, ...
                    subNumber, sessions{iSes}, runs{iRun}, opt);

                % check that the file with the right prefix exist
                files = inputFileValidation(subFuncDataDir, prefix, fileName);

                % add the files to list
                allFilesTemp = cellstr(files);
                allFiles = [allFiles; allFilesTemp];
                sesCounter = sesCounter + 1;

            end
        end

    matlabbatch{1}.spm.spatial.smooth.data=  allFiles;
    % Define the amount of smoothing required
    matlabbatch{1}.spm.spatial.smooth.fwhm = [mmSmoothing mmSmoothing mmSmoothing];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = ...
        [spm_get_defaults('smooth.prefix'), num2str(mmSmoothing)];  % Prefix = s+NumberOfSmoothing

    %% SAVE THE MATLABBATCH
    %Create the JOBS directory if it doesnt exist
    JOBS_dir = fullfile(opt.JOBS_dir, subNumber);
    [~, ~, ~] = mkdir(JOBS_dir);

    save(fullfile(JOBS_dir, 'jobs_Smoothing_matlabbatch_SPM12.mat'), 'matlabbatch') % save the matlabbatch
    spm_jobman('run',matlabbatch)

    end
end


end
