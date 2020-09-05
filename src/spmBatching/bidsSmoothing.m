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

    % creates prefix to look for
    prefix = getPrefix('smoothing', opt);

    %% Loop through the groups, subjects, and sessions
    for iGroup = 1:length(group)

        groupName = group(iGroup).name;

        for iSub = 1:group(iGroup).numSub

            subID = group(iGroup).subNumber{iSub};

            fprintf(1, 'PREPARING: SMOOTHING JOB \n');

            sesCounter = 1;                 % file/loop counter

            % identify sessions for this subject
            [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

            % clear previous matlabbatch and files
            matlabbatch = [];
            allFiles = [];

            for iSes = 1:nbSessions        % For each session

                % get all runs for that subject across all sessions
                [runs, nbRuns] = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

                % numRuns = group(iGroup).numRuns(iSub);
                for iRun = 1:nbRuns

                    printProcessingRun(groupName, iSub, subID, iSes, iRun);

                    % get the filename for this bold run for this task
                    [fileName, subFuncDataDir] = getBoldFilename( ...
                        BIDS, ...
                        subID, sessions{iSes}, runs{iRun}, opt);

                    % check that the file with the right prefix exist
                    files = inputFileValidation(subFuncDataDir, prefix, fileName);

                    % add the files to list
                    allFilesTemp = cellstr(files);
                    allFiles = [allFiles; allFilesTemp]; %#ok<AGROW>
                    sesCounter = sesCounter + 1;

                end
            end

            matlabbatch{1}.spm.spatial.smooth.data =  allFiles;
            % Define the amount of smoothing required
            matlabbatch{1}.spm.spatial.smooth.fwhm = [funcFWHM funcFWHM funcFWHM];
            matlabbatch{1}.spm.spatial.smooth.dtype = 0;
            matlabbatch{1}.spm.spatial.smooth.im = 0;

            % Prefix = s+NumberOfSmoothing
            matlabbatch{1}.spm.spatial.smooth.prefix = ...
                [spm_get_defaults('smooth.prefix'), num2str(funcFWHM)];

            %% SAVE THE MATLABBATCH
            % Create the JOBS directory if it doesnt exist
            jobsDir = fullfile(opt.JOBS_dir, subID);
            [~, ~, ~] = mkdir(jobsDir);

            save(fullfile(jobsDir, 'jobs_matlabbatch_SPM12_Smoothing.mat'), ...
                'matlabbatch');

            spm_jobman('run', matlabbatch);

        end
    end

end
