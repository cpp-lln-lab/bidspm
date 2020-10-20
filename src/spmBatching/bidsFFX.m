% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function bidsFFX(action, opt, funcFWHM, isMVPA)
    % bidsFFX(action, funcFWHM, opt, isMVPA)
    %
    % This scripts builds up the design matrix for each subject.
    % It has to be run in 2 separate steps (action):
    %
    % Inputes
    % - action (string)
    %   - case specifyAndEstimate = fMRI design and estimate
    %   - case contrasts = contrasts
    % - funcFWHM (scalar) is the number of the mm smoothing used in the
    %   normalized functional files.
    %     for unsmoothed data  funcFWHM = 0
    %     for smoothed data = ... mm
    % In this way we can make multiple ffx for different smoothing degrees

    % if input has no opt, load the opt.mat file
    if nargin < 3
        opt = [];
    end
    opt = loadAndCheckOptions(opt);

    if nargin < 4
        isMVPA = 0;
    end

    % load the subjects/Groups information and the task name
    [group, opt, BIDS] = getData(opt);

    %% Loop through the groups, subjects, and sessions
    for iGroup = 1:length(group)

        groupName = group(iGroup).name;

        for iSub = 1:group(iGroup).numSub

            subID = group(iGroup).subNumber{iSub};

            mvpaSuffix = setMvpaSuffix(isMVPA);

            printProcessingSubject(groupName, iSub, subID);

            switch action

                case 'specifyAndEstimate'

                    fprintf(1, 'BUILDING JOB : FMRI design\n');

                    matlabbatch = setBatchSubjectLevelGLMSpec( ...
                                                              BIDS, opt, subID, funcFWHM, isMVPA);

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

                    saveMatlabBatch(matlabbatch, ...
                                    ['specifyAndEstimateFfx_task-', opt.taskName, ...
                                     '_FWHM-', num2str(funcFWHM), ...
                                     mvpaSuffix], ...
                                    opt, subID);

                case 'contrasts'

                    fprintf(1, 'BUILDING JOB : FMRI contrasts\n');

                    matlabbatch = setBatchSubjectLevelContrasts(opt, subID, funcFWHM, isMVPA);

                    saveMatlabBatch(matlabbatch, ...
                                    ['contrastsFfx_task-', opt.taskName, ...
                                     '_FWHM-', num2str(funcFWHM), ...
                                     mvpaSuffix], ...
                                    opt, subID);

            end

            spm_jobman('run', matlabbatch);

        end
    end

end
