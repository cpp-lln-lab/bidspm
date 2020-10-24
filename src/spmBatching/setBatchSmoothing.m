% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function matlabbatch = setBatchSmoothing(BIDS, opt, subID, funcFWHM)

    % creates prefix to look for
    prefix = getPrefix('smoothing', opt);
    if strcmp(opt.space, 'individual')
        prefix = getPrefix('smoothing_space-individual', opt);
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

            % get the filename for this bold run for this task
            [fileName, subFuncDataDir] = getBoldFilename( ...
                                                         BIDS, ...
                                                         subID, sessions{iSes}, runs{iRun}, opt);

            % check that the file with the right prefix exist
            files = validationInputFile(subFuncDataDir, prefix, fileName);

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
