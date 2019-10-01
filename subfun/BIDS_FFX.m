function BIDS_FFX(action, degreeOfSmoothing, opt)
% This scripts builds up the design matrix for each subject.
% It has to be run in 2 separate steps (action) :
% case 1 = fMRI design and estimate
% case 2 = contrasts
% Adjust your contrasts as a subfunction at the end of the script

% degreeOfSmoothing is the number of the mm smoothing used in the
% normalized functional files. for unsmoothied data  degreeOfSmoothing = 0
% for smoothed data = ... mm
% in this way we can make multiple ffx for different smoothing degrees
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% if input has no opt, load the opt.mat file
if nargin<3
    load('opt.mat')
    fprintf('opt.mat file loaded \n\n')
end



%%
% load the subjects/Groups information and the task name
[group, opt, BIDS] = getData(opt);

% creates prefix to look for
[prefix, motionRegressorPrefix] = getPrefix('FFX', opt, degreeOfSmoothing);

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
numberTimeBins = numel(unique(sliceOrder));
refBin = floor(numberTimeBins/2);

%%

switch action
    case 1 % fMRI design and estimate
        tic

        %% Loop through the groups, subjects, and sessions
        for iGroup= 1:length(group)              % For each group
            groupName = group(iGroup).name ;     % Get the Group name

            for iSub = 1:group(iGroup).numSub    % For each Subject in the group

                % clear previous matlabbatch
                matlabbatch = [];

                subNumber = group(iGroup).subNumber{iSub} ;   % Get the Subject ID

                fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s \n',...
                    groupName,iSub,subNumber)

                matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
                matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR ;
                matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = numberTimeBins;
                matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = refBin;

                % The Directory to save the FFX files (Create it if it doesnt exist)
                ffxDir = getFFXdir(subNumber, degreeOfSmoothing, opt);

                if exist(ffxDir,'dir') % If it exists, issue a warning that it has been overwritten
                    fprintf(1,'A DIRECTORY WITH THIS NAME ALREADY EXISTED AND WAS OVERWRITTEN, SORRY \n');
                    rmdir(ffxDir,'s')
                    mkdir(ffxDir)
                end
                matlabbatch{1}.spm.stats.fmri_spec.dir = {ffxDir};
                % FMRI DESIGN
                fprintf(1,'BUILDING JOB : FMRI design\n')

                sesCounter = 1;


                %%
                % identify sessions for this subject
                [sessions, numSessions] = getSessions(BIDS, subNumber, opt);

                for iSes = 1:numSessions % For each session

                    % get all runs for that subject across all sessions
                    [runs, numRuns] = getRuns(BIDS, subNumber, sessions{iSes}, opt);

                    for iRun = 1:numRuns % For each run

                        fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s SESSION: %i RUN:  %i \n',...
                            groupName,iSub,subNumber,iSes,iRun)

                        % get the filename for this bold run for this task
                        [fileName, subFuncDataDir]= getBoldFilename(...
                            BIDS, ...
                            subNumber, sessions{iSes}, runs{iRun}, opt);

                        % check that the file with the right prefix exist
                        files = inputFileValidation(subFuncDataDir, prefix, fileName);

                        disp(files)

                        tsvFile{sesCounter,1} = fullfile(subFuncDataDir, ...
                            [fileName(1:end-9),'_events.tsv']); %#ok<*AGROW>
                        rpFile{sesCounter,1} = ...
                            fullfile(subFuncDataDir, ...
                            ['rp_', motionRegressorPrefix, fileName(1:end-4),'.txt']);










                        % Convert the tsv files to a mat file to be used by SPM
                        % DO WE NEED TO TRIM ONSET BY A DURATION EQUIVALENT
                        % TO THE NUMBER OF DUMMIES REMOVED
                        convertTsv2mat(tsvFile{sesCounter,1})









                        matlabbatch{1}.spm.stats.fmri_spec.sess(sesCounter).scans = cellstr(files);

                        [path, file] = spm_fileparts(tsvFile{sesCounter,1});
                        condfiles = fullfile(path,['Onsets_', file, '.mat']);

                        % multicondition selection
                        matlabbatch{1}.spm.stats.fmri_spec.sess(sesCounter).cond = ...
                            struct('name', {}, 'onset', {}, 'duration', {});
                        matlabbatch{1}.spm.stats.fmri_spec.sess(sesCounter).multi = ...
                            cellstr(condfiles(:,:));
                        % multiregressor selection
                        matlabbatch{1}.spm.stats.fmri_spec.sess(sesCounter).regress = ...
                            struct('name', {}, 'val', {});
                        matlabbatch{1}.spm.stats.fmri_spec.sess(sesCounter).multi_reg = ...
                            cellstr(rpFile{sesCounter,1});

                        % The following lines are commented out because those parameters
                        % can be set in the spm_my_defaults.m
                        %                          matlabbatch{1}.spm.stats.fmri_spec.sess(ses_counter).hpf = 128;

                        sesCounter = sesCounter +1;
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
                fprintf(1,'BUILDING JOB : FMRI estimate\n')
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep;
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tname = 'Select SPM.mat';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).sname = ...
                    'fMRI model specification: SPM.mat File';
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_exbranch = ...
                    substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
                matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_output = ...
                    substruct('.','spmmat');
                matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
                matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;


                %Create the JOBS directory if it doesnt exist
                JOBS_dir = fullfile(opt.JOBS_dir, subNumber);
                [~, ~, ~] = mkdir(JOBS_dir);

                save(fullfile(JOBS_dir, ['jobs_matlabbatch_SPM12_ffx_',...
                    num2str(degreeOfSmoothing),'_',opt.taskName,'.mat']), ...
                    'matlabbatch')

                spm_jobman('run',matlabbatch)

            end
        end


    case 2  % CONTRASTS
        tic

        fprintf(1,'BUILDING JOB : FMRI contrasts\n')

        %% Loop through the groups, subjects, and sessions
        for iGroup= 1:length(group)                     % For each group
            groupName = group(iGroup).name ;            % Get the group name
            for iSub = 1:group(iGroup).numSub           % For each subject in the group

                matlabbatch = [];
                subNumber = group(iGroup).subNumber{iSub} ;  % Get the Subject ID
                fprintf(1,'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s \n',...
                    groupName,iSub,subNumber)

                % ffx folder
                ffxDir = getFFXdir(subNumber, degreeOfSmoothing, opt);

                JOBS_dir = fullfile(opt.JOBS_dir, subNumber);

                % Create Contrasts
                [~, contrasts] = pmCon(ffxDir, opt.taskName, opt);

                matlabbatch{1}.spm.stats.con.spmmat = cellstr(fullfile(ffxDir,'SPM.mat'));

                for icon = 1:size(contrasts,2)
                    matlabbatch{1}.spm.stats.con.consess{icon}.tcon.name = contrasts(icon).name;
                    matlabbatch{1}.spm.stats.con.consess{icon}.tcon.convec = contrasts(icon).C;
                    matlabbatch{1}.spm.stats.con.consess{icon}.tcon.sessrep = 'none';
                end

                matlabbatch{1}.spm.stats.con.delete = 1;

                % Save ffx matlabbatch in JOBS
                save(fullfile(JOBS_dir, ...
                    ['jobs_matlabbatch_SPM12_ffx_',...
                    num2str(degreeOfSmoothing),'_',...
                    opt.taskName,'_Contrasts.mat']), ...
                    'matlabbatch') % save the matlabbatch

                spm_jobman('run',matlabbatch)
                toc
            end

        end % switch
end

end
