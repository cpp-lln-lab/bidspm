% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function concatBetaImgTmaps(funcFWHM, opt, deleteIndBeta, deleteIndTmaps)
    % concatBetaImgTmaps(funcFWHM, opt, deleteIndBeta, deleteIndTmaps)
    %
    % Make 4D images of beta and t-maps for the MVPA
    %
    % Inputs
    % funcFWHM - smoothing (FWHM) applied to the the normalized EPI
    % opt - options structure defined by the getOption function. If no inout is given
    %   this function will attempt to load a opt.mat file in the same directory
    %   to try to get some options
    %
    % deleteIndBeta, deleteIndTmaps: boolean to decide to delete
    %  original t-maps, beta-maps or ResMaps (default = true)

    % delete individual Beta and tmaps
    if nargin < 3
        deleteIndBeta = 1;
        deleteIndTmaps = 1;
    end

    % load the subjects/Groups information and the task name
    [group, opt, ~] = getData(opt);

    %% Loop through the groups, subjects
    for iGroup = 1:length(group)

        for iSub = 1:group(iGroup).numSub

            subID = group(iGroup).subNumber{iSub};

            fprintf(1, 'PREPARING: 4D maps: %s \n', subID);

            ffxDir = getFFXdir(subID, funcFWHM, opt, isMVPA);

            load(fullfile(ffxDir, 'SPM.mat'));

            contrasts = specifyContrasts(ffxDir, opt.taskName, opt, isMVPA);

            beta_maps = cell(length(contrasts), 1);
            t_maps = cell(length(contrasts), 1);

            % path to beta and t-map files.
            for iContrast = 1:length(beta_maps)
                % Note that the betas are created from the idx (Beta_idx(iBeta))
                fileName = sprintf('beta_%04d.nii', find(contrasts(iContrast).C));
                fileName = inputFileValidation(ffxDir, '', fileName);
                beta_maps{iContrast, 1} = [fileName{1}, ',1'];

                % while the contrastes (t-maps) are not from the index. They were created
                fileName = sprintf('spmT_%04d.nii', iContrast);
                fileName = inputFileValidation(ffxDir, '', fileName);
                t_maps{iContrast, 1} = [fileName{1}, ',1'];
            end

            % clear previous matlabbatch and files
            matlabbatch = [];

            % 4D beta maps
            matlabbatch{1}.spm.util.cat.vols = beta_maps;
            matlabbatch{1}.spm.util.cat.name = ['4D_beta_', num2str(funcFWHM), '.nii'];
            matlabbatch{1}.spm.util.cat.dtype = 4;

            % 4D t-maps
            matlabbatch{2}.spm.util.cat.vols = t_maps;
            matlabbatch{2}.spm.util.cat.name = ['4D_t_maps_', num2str(funcFWHM), '.nii'];
            matlabbatch{2}.spm.util.cat.dtype = 4;

            saveMatlabBatch(matlabbatch, 'concatBetaImgTmaps', opt, subID);

            spm_jobman('run', matlabbatch);

            removeBetaImgTmaps(beta_maps, t_maps, deleteIndBeta, deleteIndTmaps);

        end
    end

end

function removeBetaImgTmaps(beta_maps, t_maps, deleteIndBeta, deleteIndTmaps)

    % delete maps
    if deleteIndBeta

        % delete all individual beta maps
        fprintf('Deleting individual beta-maps ...  ');
        for iBeta = 1:length(beta_maps)
            delete(beta_maps{iBeta}(1:end - 2));
        end
        fprintf('Done. \n\n\n ');

    end

    if  deleteIndTmaps

        % delete all individual con maps
        fprintf('Deleting individual con maps ...  ');
        for iCon = 1:length(t_maps)
            delete(fullfile(ffxDir, ['con_', sprintf('%04d', iCon), '.nii']));
        end
        fprintf('Done. \n\n\n ');

        % delete all individual t-maps
        fprintf('Deleting individual t-maps ...  ');
        for iTmap = 1:length(t_maps)
            delete(t_maps{iTmap}(1:end - 2));
        end
        fprintf('Done. \n\n\n ');
    end

    % delete mat files

    % This is refactorable
    % ex: delete(fullfile(ffxDir, ['4D_*', num2str(funcFWHM), '.mat']));

    if exist(fullfile(ffxDir, ['4D_beta_', num2str(funcFWHM), '.mat']), 'file')
        delete(fullfile(ffxDir, ['4D_beta_', num2str(funcFWHM), '.mat']));
    end
    if exist(fullfile(ffxDir, ['4D_t_maps_', num2str(funcFWHM), '.mat']), 'file')
        delete(fullfile(ffxDir, ['4D_t_maps_', num2str(funcFWHM), '.mat']));
    end
end
