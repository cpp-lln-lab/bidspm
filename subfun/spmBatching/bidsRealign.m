function bidsRealign(opt)
    %% The scripts realigns the functional

    %% TO DO
    % find a way to paralelize this over subjects

    % if input has no opt, load the opt.mat file
    if nargin < 1
        load('opt.mat');
        fprintf('opt.mat file loaded \n\n');
    end

    % load the subjects/Groups information and the task name
    [group, opt, BIDS] = getData(opt);

    % creates prefix to look for
    prefix = getPrefix('preprocess', opt);

    fprintf(1, 'DOING PREPROCESSING\n');

    %% Loop through the groups, subjects, and sessions
    for iGroup = 1:length(group)

        groupName = group(iGroup).name;

        for iSub = 1:group(iGroup).numSub

            matlabbatch = [];
            % Get the ID of the subject
            % (i.e SubNumber doesnt have to match the iSub if one subject
            % is exluded for any reason)
            subNumber = group(iGroup).subNumber{iSub}; % Get the subject ID
            fprintf(1, ' PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s \n', ...
                groupName, iSub, subNumber);

            % identify sessions for this subject
            [sessions, nbSessions] = getInfo(BIDS, subNumber, opt, 'Sessions');

            %% REALIGN
            fprintf(1, ' BUILDING SPATIAL JOB : REALIGN\n');
            sesCounter = 1;

            for iSes = 1:nbSessions  % For each session

                % get all runs for that subject across all sessions
                [runs, nbRuns] = getInfo(BIDS, subNumber, opt, 'Runs', sessions{iSes});

                for iRun = 1:nbRuns  % For each run

                    % get the filename for this bold run for this task
                    [fileName, subFuncDataDir] = getBoldFilename( ...
                        BIDS, ...
                        subNumber, sessions{iSes}, runs{iRun}, opt);

                    % check that the file with the right prefix exist
                    files = inputFileValidation(subFuncDataDir, prefix, fileName);

                    % get native resolution to reuse it at normalisation;
                    if ~isempty(opt.funcVoxelDims) % If voxel dimensions is defined in the opt
                        voxDim = opt.funcVoxelDims; % Get the dimension values
                    else
                        % SPM Doesnt deal with nii.gz and all our nii will be unzipped
                        % at this stage
                        hdr = spm_vol(fullfile(subFuncDataDir, [prefix, fileName]));
                        voxDim = diag(hdr(1).mat);
                        % Voxel dimensions are not pure integers before reslicing, therefore
                        % Round the dimensions of the functional files to the 1st decimal point
                        voxDim = abs(voxDim(1:3)');
                        voxDim = round(voxDim * 10) / 10;
                        % Add it to opt.funcVoxelDims to have the same value for
                        % all subjects and sessions
                        opt.funcVoxelDims = voxDim;
                    end

                    fprintf(1, ' %s\n', files{1});

                    matlabbatch{1}.spm.spatial.realign.estwrite.data{sesCounter} = ...
                        cellstr(files);

                    sesCounter = sesCounter + 1;

                end
            end

            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = {''};

            % The following lines are commented out because those parameters
            % can be set in the spm_my_defaults.m
            % matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 1;
            % matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 2;
            % matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
            % matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
            % matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
            % matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
            % matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [0 1];
            % matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 3;
            % matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
            % matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;

            %% SAVING JOBS
            % Create the JOBS directory if it doesnt exist
            JOBS_dir = fullfile(opt.JOBS_dir, subNumber);
            [~, ~, ~] = mkdir(JOBS_dir);

            save(fullfile(JOBS_dir, 'jobs_matlabbatch_SPM12_SpatialPrepocess.mat'), ...
                'matlabbatch'); % save the matlabbatch
            spm_jobman('run', matlabbatch);

        end
    end

end
