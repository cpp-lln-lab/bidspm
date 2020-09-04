function bidsRFX(action, mmFunctionalSmoothing, mmConSmoothing, opt, isMVPA)
    % This script smooth all con images created at the fisrt level in each
    % subject, create a mean structural image and mean mask over the
    % population, process the factorial design specification  and estimation
    %  and estimate Contrats.
    %
    % INPUTS
    % - action
    %   - case 1 : smooth con images
    %   - case 2 : Mean Struct, MeanMask, Factorial design specification and
    %      estimation, Contrst estimation
    %
    % - mmFunctionalSmoothing = How much smoothing was applied to the functional
    %    data in the preprocessing
    % - mmConSmoothing = How much smoothing is required for the CON images for
    %    the second level analysis
    %
    % Your input is twofold :
    % 1. Specify your data at the beginning of the script
    % 2. In the origdir, create a structure containing all possible contrasts,
    % example: ConOfInterest.mat containing the structure Session.con (contrasts of
    %  interest by group)
    % IMPORTANT: To create the structure, use the script "List_of_Contrast.m"
    % The Contrast names should match those in the single level FFX and in THE
    % SAME ORDER.

    % if input has no opt, load the opt.mat file
    if nargin < 4
        load('opt.mat');
        fprintf('opt.mat file loaded \n\n');
    end

    if nargin < 5
        isMVPA = 0;
    end

    % load the subjects/Groups information and the task name
    [group, opt, BIDS] = getData(opt);

    % JOBS Directory
    JOBS_dir = fullfile(opt.JOBS_dir);

    % Check which level of CON smoothing is desired
    if mmConSmoothing == 0
        smoothOrNonSmooth = '';
    elseif mmConSmoothing > 0
        smoothOrNonSmooth = ['s', num2str(mmConSmoothing)];
    else
        error ('Check you Con files');
    end

    switch action
        case 1 % Smooth all con images

            matlabbatch = {};
            counter = 0;

            %% Loop through the groups, subjects, and sessions
            for iGroup = 1:length(group)

                groupName = group(iGroup).name;    % Get the Group Name

                for iSub = 1:group(iGroup).numSub   % For each subject
                    counter = counter + 1;
                    subNumber = group(iGroup).subNumber{iSub};   % Get the Subject ID

                    fprintf(1, 'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s \n', ...
                        groupName, iSub, subNumber);

                    % FFX Directory
                    ffxDir = getFFXdir(subNumber, mmFunctionalSmoothing, opt, isMVPA);
                    conImg = spm_select('FPlist', ffxDir, '^con*.*nii$');
                    matlabbatch{counter}.spm.spatial.smooth.data = cellstr(conImg);

                    % Define how much smoothing is required
                    matlabbatch{counter}.spm.spatial.smooth.fwhm = ...
                        [mmConSmoothing mmConSmoothing mmConSmoothing];
                    matlabbatch{counter}.spm.spatial.smooth.dtype = 0;
                    matlabbatch{counter}.spm.spatial.smooth.prefix = [ ...
                      spm_get_defaults('smooth.prefix'), num2str(mmConSmoothing)];

                end
            end

            % save the matlabbatch
            [~, ~, ~] = mkdir(JOBS_dir);
            save(fullfile(JOBS_dir, ...
                ['jobs_matlabbatch_SPM12_SmoothCon_', ...
                num2str(mmConSmoothing), '_', ...
                opt.taskName, '_Contrasts.mat']), ...
                'matlabbatch'); % save the matlabbatch

            fprintf(1, 'SMOOTHING CON IMAGES...');
            spm_jobman('run', matlabbatch);

        case 2

            matlabbatch = {};

            % Define the RFX folder name and create it in the derivatives
            % directory
            RFX_FolderName = fullfile(opt.dataDir, '..', 'derivatives', 'SPM12_CPPL', ...
                ['RFX_', opt.taskName], ...
                ['RFX_FunctSmooth', num2str(mmFunctionalSmoothing), ...
                '_ConSmooth_', num2str(mmConSmoothing)]);

            [~, ~, ~] = mkdir(RFX_FolderName);

            % Create Mean Structural Image
            fprintf(1, 'BUILDING JOB: Create Mean Structural Image...');

            subCounter = 0;

            for iGroup = 1:length(group)                    % For each group

                groupName = group(iGroup).name;           % Get the group name

                for iSub = 1:group(iGroup).numSub          % For each subject

                    subCounter = subCounter + 1;

                    subNumber = group(iGroup).subNumber{iSub};   % Get the Subject ID

                    fprintf(1, 'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %s \n', ...
                        groupName, iSub, subNumber);

                    %% STRUCTURAL
                    struct = spm_BIDS(BIDS, 'data', ...
                        'sub', subNumber, ...
                        'type', 'T1w');
                    % we assume that the first T1w is the correct one (could be an
                    % issue for data set with more than one
                    struct = struct{1};

                    [subStrucDataDir, file, ext] = spm_fileparts(struct);

                    % get filename of the orginal file (drop the gunzip extension)
                    if strcmp(ext, '.gz')
                        fileName = file;
                    elseif strcmp(ext, '.nii')
                        fileName = [file ext];
                    end

                    files = inputFileValidation( ...
                        subStrucDataDir, ...
                        [spm_get_defaults('normalise.write.prefix'), ...
                        spm_get_defaults('deformations.modulate.prefix')], ...
                        fileName);

                    matlabbatch{1}.spm.util.imcalc.input{subCounter, :} = files{1};

                    %% Mask
                    ffxDir = getFFXdir(subNumber, mmFunctionalSmoothing, opt, isMVPA);

                    files = inputFileValidation(ffxDir, '', 'mask.nii');

                    matlabbatch{2}.spm.util.imcalc.input{subCounter, :} = files{1};

                end
            end

            %% Generate the equation to get the mean of the mask and structural image
            % example : if we have 5 subjects, Average equation = '(i1+i2+i3+i4+i5)/5'
            numImg = subCounter;
            imgNum  = 1:subCounter;

            tmpImg = sprintf('+i%i', imgNum);
            tmpImg = tmpImg(2:end);

            sumEquation = ['(', tmpImg, ')'];
            % meanStruct_equation = '(i1+i2+i3+i4+i5)/5'
            meanStruct_equation = ['(', tmpImg, ')/', num2str(length(imgNum))];
            % meanMask_equation = '(i1+i2+i3+i4+i5)>0.75*5'
            meanMask_equation = strcat(sumEquation, '>0.75*', num2str(numImg));

            %% The mean structural will be saved in the RFX folder
            matlabbatch{1}.spm.util.imcalc.output = 'MeanStruct.nii';
            matlabbatch{1}.spm.util.imcalc.outdir{:} = RFX_FolderName;
            matlabbatch{1}.spm.util.imcalc.expression = meanStruct_equation;
            matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{1}.spm.util.imcalc.options.mask = 0;
            matlabbatch{1}.spm.util.imcalc.options.interp = 1;
            matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

            %% The mean mask will be saved in the RFX folder
            matlabbatch{2}.spm.util.imcalc.output = 'MeanMask.nii';
            matlabbatch{2}.spm.util.imcalc.outdir{:} = RFX_FolderName;
            matlabbatch{2}.spm.util.imcalc.expression = meanMask_equation;
            matlabbatch{2}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{2}.spm.util.imcalc.options.mask = 0;
            matlabbatch{2}.spm.util.imcalc.options.interp = 1;
            matlabbatch{2}.spm.util.imcalc.options.dtype = 4;

            fprintf(1, 'Create Mean Struct and Mask IMAGES...');

            % save the matlabbatch
            [~, ~, ~] = mkdir(JOBS_dir);
            save(fullfile(JOBS_dir, ...
                'jobs_matlabbatch_SPM12_CreateMeanStrucMask.mat'), ...
                'matlabbatch');

            spm_jobman('run', matlabbatch);

            %% Factorial design specification

            % Load the list of contrasts of interest for the RFX
            % model = spm_jsonread(opt.model.file);
            if isMVPA
                model = spm_jsonread(opt.model.multivariate.file);
            else
                model = spm_jsonread(opt.model.univariate.file);
            end

            for iStep = 1:length(model.Steps)
                if strcmp(model.Steps{iStep}.Level, 'dataset')
                    grpLvlCon = model.Steps{iStep}.AutoContrasts;
                    break
                end
            end

            fprintf(1, 'BUILDING JOB: Factorial Design Specification');

            con = 0;

            matlabbatch = {};

            % For each contrast
            for j = 1:size(grpLvlCon, 1)

                % the strrep(Session{j}, 'trial_type.', '') is there to remove
                % 'trial_type.' because contrasts against baseline are renamed
                % at the subject level
                conName = rmTrialTypeStr(grpLvlCon{j});

                con = con + 1;

                % For each group
                for iGroup = 1:length(group)

                    groupName = group(iGroup).name;

                    matlabbatch{j}.spm.stats.factorial_design.des.fd.icell(iGroup).levels = ...
                        iGroup; %#ok<*AGROW>

                    for iSub = 1:group(iGroup).numSub       % For each subject
                        subNumber = group(iGroup).subNumber{iSub};  % Get the subject ID
                        fprintf(1, 'PROCESSING GROUP: %s SUBJECT No.: %i SUBJECT ID : %i \n', ...
                            groupName, iSub, subNumber);

                        % FFX directory and load SPM.mat of that subject
                        ffxDir = getFFXdir(subNumber, mmFunctionalSmoothing, opt, isMVPA);
                        load(fullfile(ffxDir, 'SPM.mat'));

                        % find which contrast of that subject has the name of the contrast we
                        % want to bring to the group level
                        conIdx = find(strcmp({SPM.xCon.name}, conName));
                        fileName = sprintf('con_%0.4d.nii', conIdx);
                        file = inputFileValidation(ffxDir, smoothOrNonSmooth, fileName);

                        matlabbatch{j}.spm.stats.factorial_design.des.fd.icell(iGroup).scans(iSub, :) = ...
                            file;

                    end

                end

                % GROUP and the number of levels in the group. if 2 groups ,
                % then number of levels = 2
                matlabbatch{j}.spm.stats.factorial_design.des.fd.fact.name = 'GROUP';
                matlabbatch{j}.spm.stats.factorial_design.des.fd.fact.levels = 1;
                matlabbatch{j}.spm.stats.factorial_design.des.fd.fact.dept = 0;

                % 1: Assumes that the variance is not the same across groups
                % 0: There is no difference in the variance between groups
                matlabbatch{j}.spm.stats.factorial_design.des.fd.fact.variance = 1;
                matlabbatch{j}.spm.stats.factorial_design.des.fd.fact.gmsca = 0;
                matlabbatch{j}.spm.stats.factorial_design.des.fd.fact.ancova = 0;
                % matlabbatch{j}.spm.stats.factorial_design.cov = [];
                matlabbatch{j}.spm.stats.factorial_design.masking.tm.tm_none = 1;
                matlabbatch{j}.spm.stats.factorial_design.masking.im = 1;
                matlabbatch{j}.spm.stats.factorial_design.masking.em = { ...
                    fullfile(RFX_FolderName, 'MeanMask.nii')};
                matlabbatch{j}.spm.stats.factorial_design.globalc.g_omit = 1;
                matlabbatch{j}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
                matlabbatch{j}.spm.stats.factorial_design.globalm.glonorm = 1;

                % If it exists, issue a warning that it has been overwritten
                if exist(fullfile(RFX_FolderName, conName), 'dir')
                    warning('overwriting directory: %s \n', fullfile(RFX_FolderName, conName));
                    rmdir(fullfile(RFX_FolderName, conName), 's');
                end

                mkdir(fullfile(RFX_FolderName, conName));
                matlabbatch{j}.spm.stats.factorial_design.dir = { fullfile(RFX_FolderName, conName) };

            end

            % Go to Jobs directory and save the matlabbatch
            % save the matlabbatch
            save(fullfile(JOBS_dir, ...
                'jobs_matlabbatch_SPM12_RFX_specification.mat'), ...
                'matlabbatch');

            fprintf(1, 'Factorial Design Specification...');
            spm_jobman('run', matlabbatch);

            %% Factorial design estimation
            fprintf(1, 'BUILDING JOB: Factorial Design Estimation');

            matlabbatch = {};

            for j = 1:size(grpLvlCon, 1)
                conName = rmTrialTypeStr(grpLvlCon{j});
                matlabbatch{j}.spm.stats.fmri_est.spmmat = ...
                    { fullfile(RFX_FolderName, conName, 'SPM.mat') };
                matlabbatch{j}.spm.stats.fmri_est.method.Classical = 1;
            end

            % Go to Jobs directory and save the matlabbatch
            % save the matlabbatch
            save(fullfile(JOBS_dir, ...
                'jobs_matlabbatch_SPM12_RFX_estimation.mat'), ...
                'matlabbatch');

            fprintf(1, 'Factorial Design Estimation...');
            spm_jobman('run', matlabbatch);

            %% Contrast estimation
            fprintf(1, 'BUILDING JOB: Contrast estimation');

            matlabbatch = {};

            % ADD/REMOVE CONTRASTS DEPENDING ON YOUR EXPERIMENT AND YOUR GROUPS
            for j = 1:size(grpLvlCon, 1)
                conName = rmTrialTypeStr(grpLvlCon{j});
                matlabbatch{j}.spm.stats.con.spmmat = ...
                    {fullfile(RFX_FolderName, conName, 'SPM.mat')};
                matlabbatch{j}.spm.stats.con.consess{1}.tcon.name = 'GROUP';
                matlabbatch{j}.spm.stats.con.consess{1}.tcon.convec = 1;
                matlabbatch{j}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

                matlabbatch{j}.spm.stats.con.delete = 0;
            end

            % save the matlabbatch
            save(fullfile(JOBS_dir, ...
                'jobs_matlabbatch_SPM12_RFX_contrasts.mat'), ...
                'matlabbatch');

            fprintf(1, 'Contrast Estimation...');
            spm_jobman('run', matlabbatch);

    end

end

function conName = rmTrialTypeStr(conName)
    conName = strrep(conName, 'trial_type.', '');
end
