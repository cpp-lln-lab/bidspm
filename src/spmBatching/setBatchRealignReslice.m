function matlabbatch = setBatchRealignReslice(BIDS, opt, subID)

    % identify sessions for this subject
    [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

    prefix = getPrefix('preprocess', opt);

    matlabbatch = [];

    sesCounter = 1;

    for iSes = 1:nbSessions  % For each session

        % get all runs for that subject across all sessions
        [runs, nbRuns] = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

        for iRun = 1:nbRuns  % For each run

            % get the filename for this bold run for this task
            [fileName, subFuncDataDir] = getBoldFilename( ...
                BIDS, ...
                subID, sessions{iSes}, runs{iRun}, opt);

            % check that the file with the right prefix exist
            files = inputFileValidation(subFuncDataDir, prefix, fileName);

            fprintf(1, ' %s\n', files{1});

            matlabbatch{1}.spm.spatial.realign.estwrite.data{sesCounter} = ...
                cellstr(files);

            sesCounter = sesCounter + 1;

        end
    end

    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = {''};

    % The following lines are commented out because those parameters
    % can be set in the spm_my_defaults.m
    % matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 1;
    % matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 2;
    % matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    % matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    % matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    % matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    % matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1];
    % matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 3;
    % matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    % matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;

end
