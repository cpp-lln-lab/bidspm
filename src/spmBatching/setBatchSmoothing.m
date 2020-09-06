function matlabbatch = setBatchSmoothing(BIDS, subID, opt, funcFWHM, groupName)

    % creates prefix to look for
    prefix = getPrefix('smoothing', opt);
    if strcmp(opt.space, 'T1w')
        prefix = getPrefix('smoothing_space-T1w', opt);
    end

    % identify sessions for this subject
    [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

    % clear previous matlabbatch and files
    matlabbatch = [];
    allFiles = [];

    sesCounter = 1;

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

    % Prefix = s+funcFWHM
    matlabbatch{1}.spm.spatial.smooth.prefix = ...
        [spm_get_defaults('smooth.prefix'), num2str(funcFWHM)];

end
