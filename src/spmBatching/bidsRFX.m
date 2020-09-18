% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function bidsRFX(action, funcFWHM, conFWHM, opt, isMVPA)
    % This script smooth all con images created at the fisrt level in each
    % subject, create a mean structural image and mean mask over the
    % population, process the factorial design specification  and estimation
    %  and estimate Contrats.
    %
    % INPUTS
    % - action
    %   - case 'smoothContrasts' : smooth con images
    %   - case 'RFX' : Mean Struct, MeanMask, Factorial design specification and
    %      estimation, Contrst estimation
    %
    % - funcFWHM = How much smoothing was applied to the functional
    %    data in the preprocessing
    % - conFWHM = How much smoothing is required for the CON images for
    %    the second level analysis
    %

    if nargin < 2 || isempty(funcFWHM)
        funcFWHM = 0;
    end

    if nargin < 3 || isempty(conFWHM)
        conFWHM = 0;
    end

    % if input has no opt, load the opt.mat file
    if nargin < 4
        load('opt.mat');
        fprintf('opt.mat file loaded \n\n');
    end

    if nargin < 5 || isempty(isMVPA)
        isMVPA = 0;
    end

    % load the subjects/Groups information and the task name
    [group, opt, ~] = getData(opt);

    switch action

        case 'smoothContrasts'

            fprintf(1, 'SMOOTHING CON IMAGES...');

            matlabbatch = setBatchSmoothConImages(group, funcFWHM, conFWHM, opt, isMVPA);

            saveMatlabBatch( ...
                ['smoothCon_FWHM-', num2str(conFWHM), '_task-', opt.taskName], ...
                'STC', ...
                opt);

            spm_jobman('run', matlabbatch);

        case 'RFX'

            fprintf(1, 'Create Mean Struct and Mask IMAGES...');

            rfxDir = getRFXdir(opt, funcFWHM, conFWHM, contrastName);

            % ------
            % TODO
            % - need to rethink where to save the anat and mask
            % - need to smooth the anat
            % - create a masked version of the anat too
            % ------

            matlabbatch = ...
                setBatchMeanAnatAndMask(opt, funcFWHM, isMVPA, rfxDir);

            % ------
            % TODO
            % needs to be improved (maybe??) as the structural and mask may vary for
            % different analysis
            % ------

            saveMatlabBatch(matlabbatch, 'createMeanStrucMask', opt);

            spm_jobman('run', matlabbatch);

            %% Factorial design specification

            % Load the list of contrasts of interest for the RFX
            grpLvlCon = getGrpLevelContrastToCompute(opt, isMVPA);

            % ------
            % TODO
            % rfxDir should probably be set in setBatchFactorialDesign
            % ------

            rfxDir = getRFXdir(opt, funcFWHM, conFWHM, contrastName);

            fprintf(1, 'BUILDING JOB: Factorial Design Specification');

            matlabbatch = setBatchFactorialDesign(grpLvlCon, group, conFWHM, rfxDir);

            % ------
            % TODO
            % needs to be improved (maybe??) as the name may vary with FXHM and
            % contrast
            % ------

            saveMatlabBatch(matlabbatch, 'rfxSpecification', opt);

            fprintf(1, 'Factorial Design Specification...');

            spm_jobman('run', matlabbatch);

            %% Factorial design estimation

            fprintf(1, 'BUILDING JOB: Factorial Design Estimation');

            matlabbatch = {};

            for j = 1:size(grpLvlCon, 1)
                conName = rmTrialTypeStr(grpLvlCon{j});
                matlabbatch{j}.spm.stats.fmri_est.spmmat = ...
                    { fullfile(rfxDir, conName, 'SPM.mat') }; %#ok<*AGROW>
                matlabbatch{j}.spm.stats.fmri_est.method.Classical = 1;
            end

            % ------
            % TODO
            % needs to be improved (maybe??) as the name may vary with FXHM and
            % contrast
            % ------

            saveMatlabBatch(matlabbatch, 'rfxEstimation', opt);

            fprintf(1, 'Factorial Design Estimation...');

            spm_jobman('run', matlabbatch);

            %% Contrast estimation

            fprintf(1, 'BUILDING JOB: Contrast estimation');

            matlabbatch = {};

            % ADD/REMOVE CONTRASTS DEPENDING ON YOUR EXPERIMENT AND YOUR GROUPS
            for j = 1:size(grpLvlCon, 1)
                conName = rmTrialTypeStr(grpLvlCon{j});
                matlabbatch{j}.spm.stats.con.spmmat = ...
                    {fullfile(rfxDir, conName, 'SPM.mat')};
                matlabbatch{j}.spm.stats.con.consess{1}.tcon.name = 'GROUP';
                matlabbatch{j}.spm.stats.con.consess{1}.tcon.convec = 1;
                matlabbatch{j}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

                matlabbatch{j}.spm.stats.con.delete = 0;
            end

            % ------
            % TODO
            % needs to be improved (maybe??) as the name may vary with FXHM and
            % contrast
            % ------

            saveMatlabBatch(matlabbatch, 'rfxContrasts', opt);

            fprintf(1, 'Contrast Estimation...');

            spm_jobman('run', matlabbatch);

    end

end

function conName = rmTrialTypeStr(conName)
    conName = strrep(conName, 'trial_type.', '');
end
