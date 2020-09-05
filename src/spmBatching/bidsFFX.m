function bidsFFX(action, FWHM, opt, isMVPA)
    % This scripts builds up the design matrix for each subject.
    % It has to be run in 2 separate steps (action) :
    % case 1 = fMRI design and estimate
    % case 2 = contrasts
    % Adjust your contrasts as a subfunction at the end of the script

    % FWHM is the number of the mm smoothing used in the
    % normalized functional files. for unsmoothied data  FWHM = 0
    % for smoothed data = ... mm
    % in this way we can make multiple ffx for different smoothing degrees
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % if input has no opt, load the opt.mat file
    if nargin < 3
        load('opt.mat');
        fprintf('opt.mat file loaded \n\n');
    end

    if nargin < 4
        isMVPA = 0;
    end

    %%
    % load the subjects/Groups information and the task name
    [group, opt, BIDS] = getData(opt);

    % creates prefix to look for
    % if opt.isMVPA
    %     [prefix, motionRegressorPrefix] = getPrefix('MVPA', opt, FWHM);
    % else
    %     [prefix, motionRegressorPrefix] = getPrefix('FFX', opt, FWHM);
    % end
    [prefix, motionRegressorPrefix] = getPrefix('FFX', opt, FWHM);

    % Check the slice timing information is not in the metadata and not added
    % manually in the opt variable.
    % Necessary to make sure that the reference slice used for slice time
    % correction is the one we center our model on
    sliceOrder = getSliceOrder(opt, 0);

    if isempty(sliceOrder)
        % no slice order defined here so we fall back on using the number of
        % slice in the first bold image of the first subject of the first group
        % to set the number of time bins we will use to upsample our model
        % during regression creation
        sub_tmp = group(1).subNumber{1};
        fileName = spm_BIDS(BIDS, 'data', ...
            'sub', sub_tmp, ...
            'type', 'bold');
        fileName = strrep(fileName{1}, '.gz', '');
        hdr = spm_vol(fileName);
        % we are assuming axial acquisition here
        sliceOrder = 1:hdr(1).dim(3);
    end

    % Get TR from metadata
    TR = opt.metadata.RepetitionTime;

    % number of times bins
    nbTimeBins = numel(unique(sliceOrder));
    refBin = floor(nbTimeBins / 2);

    %%

    switch action

        case 1 % fMRI design and estimate

            %% Loop through the groups, subjects, and sessions
            for iGroup = 1:length(group)

                groupName = group(iGroup).name;

                for iSub = 1:group(iGroup).numSub

                    % clear previous matlabbatch
                    matlabbatch = [];

                    subID = group(iGroup).subNumber{iSub};   % Get the Subject ID

                    printProcessingSubject(groupName, iSub, subID);

                    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
                    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
                    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = nbTimeBins;
                    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = refBin;

                    % The Directory to save the FFX files
                    % Create it if it doesnt exist
                    % If it exists, issue a warning that it has been overwritten
                    ffxDir = getFFXdir(subID, FWHM, opt, isMVPA);

                    if exist(ffxDir, 'dir') %
                        warning('overwriting directory: %s \n', ffxDir);
                        rmdir(ffxDir, 's');
                        mkdir(ffxDir);
                    end
                    matlabbatch{1}.spm.stats.fmri_spec.dir = {ffxDir};

                    fprintf(1, 'BUILDING JOB : FMRI design\n');

                    sesCounter = 1;

                    %%
                    % identify sessions for this subject
                    [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

                    for iSes = 1:nbSessions

                        % get all runs for that subject across all sessions
                        [runs, nbRuns] = ...
                            getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

                        for iRun = 1:nbRuns

                            printProcessingRun(groupName, iSub, subID, iSes, iRun);

                            % get the filename for this bold run for this task
                            [fileName, subFuncDataDir] = getBoldFilename( ...
                                BIDS, ...
                                subID, sessions{iSes}, runs{iRun}, opt);

                            % check that the file with the right prefix exist
                            files = inputFileValidation(subFuncDataDir, prefix, fileName);

                            disp(files);

                            tsvFile{sesCounter, 1} = fullfile(subFuncDataDir, ...
                                [fileName(1:end - 9), '_events.tsv']); %#ok<*AGROW>
                            rpFile{sesCounter, 1} = ...
                                fullfile(subFuncDataDir, ...
                                ['rp_', motionRegressorPrefix, fileName(1:end - 4), '.txt']);

                            % Convert the tsv files to a mat file to be used by SPM
                            convertTsvToMat(tsvFile{sesCounter, 1});

                            matlabbatch{1}.spm.stats.fmri_spec.sess(sesCounter).scans = ...
                                cellstr(files);

                            [path, file] = spm_fileparts(tsvFile{sesCounter, 1});
                            condfiles = fullfile(path, ['Onsets_', file, '.mat']);

                            % multicondition selection
                            matlabbatch{1}.spm.stats.fmri_spec.sess(sesCounter).cond = ...
                                struct('name', {}, 'onset', {}, 'duration', {});
                            matlabbatch{1}.spm.stats.fmri_spec.sess(sesCounter).multi = ...
                                cellstr(condfiles(:, :));

                            % multiregressor selection
                            matlabbatch{1}.spm.stats.fmri_spec.sess(sesCounter).regress = ...
                                struct('name', {}, 'val', {});
                            matlabbatch{1}.spm.stats.fmri_spec.sess(sesCounter).multi_reg = ...
                                cellstr(rpFile{sesCounter, 1});

                            % The following lines are commented out because those parameters
                            % can be set in the spm_my_defaults.m
                            %  matlabbatch{1}.spm.stats.fmri_spec.sess(ses_counter).hpf = 128;

                            sesCounter = sesCounter + 1;
                        end
                    end

                    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});

                    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];

                    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;

                    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';

                    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};

                    % The following lines are commented out because those parameters
                    % can be set in the spm_my_defaults.m
                    %                 matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

                    % FMRI ESTIMATE
                    fprintf(1, 'BUILDING JOB : FMRI estimate\n');
                    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep;
                    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tname = 'Select SPM.mat';
                    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
                    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
                    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
                    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
                    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).sname = ...
                        'fMRI model specification: SPM.mat File';
                    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_exbranch = ...
                        substruct( ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1});
                    matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_output = ...
                        substruct('.', 'spmmat');
                    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
                    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;

                    % Create the JOBS directory if it doesnt exist
                    JOBS_dir = fullfile(opt.JOBS_dir, subID);
                    [~, ~, ~] = mkdir(JOBS_dir);

                    mvpaSuffix = setMvpaSuffix(isMVPA);

                    save(fullfile(JOBS_dir, ['jobs_matlabbatch_SPM12_FFX_', mvpaSuffix, ...
                        num2str(FWHM), '_', opt.taskName, '.mat']), ...
                        'matlabbatch');

                    spm_jobman('run', matlabbatch);

                end
            end

        case 2  % CONTRASTS

            fprintf(1, 'BUILDING JOB : FMRI contrasts\n');

            computeContrasts(group, FWHM, opt, isMVPA);
    end

end

function computeContrasts(group, FWHM, opt, isMVPA)
    % Loop through the groups, subjects, and sessions

    for iGroup = 1:length(group)

        groupName = group(iGroup).name;

        for iSub = 1:group(iGroup).numSub

            matlabbatch = [];
            subID = group(iGroup).subNumber{iSub};

            printProcessingSubject(groupName, iSub, subID);

            ffxDir = getFFXdir(subID, FWHM, opt, isMVPA);

            % Create Contrasts
            contrasts = specifyContrasts(ffxDir, opt.taskName, opt, isMVPA);

            matlabbatch{1}.spm.stats.con.spmmat = cellstr(fullfile(ffxDir, 'SPM.mat'));

            for icon = 1:size(contrasts, 2)
                matlabbatch{1}.spm.stats.con.consess{icon}.tcon.name = ...
                    contrasts(icon).name;
                matlabbatch{1}.spm.stats.con.consess{icon}.tcon.convec = ...
                    contrasts(icon).C;
                matlabbatch{1}.spm.stats.con.consess{icon}.tcon.sessrep = 'none';
            end

            matlabbatch{1}.spm.stats.con.delete = 1;

            % Save ffx matlabbatch in JOBS
            jobsDir = fullfile(opt.JOBS_dir, subID);
            mvpaSuffix = setMvpaSuffix(isMVPA);
            save(fullfile(jobsDir, ...
                ['jobs_matlabbatch_SPM12_ffx_', mvpaSuffix, ...
                num2str(FWHM), '_', ...
                opt.taskName, '_Contrasts.mat']), ...
                'matlabbatch');

            spm_jobman('run', matlabbatch);

        end

    end
end
