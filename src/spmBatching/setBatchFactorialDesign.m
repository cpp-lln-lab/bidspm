% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function matlabbatch = setBatchFactorialDesign(grpLvlCon, group, conFWHM, rfxDir)

    % Check which level of CON smoothing is desired
    smoothPrefix = '';
    if conFWHM > 0
        smoothPrefix = ['s', num2str(conFWHM)];
    end

    con = 0;

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

            for iSub = 1:group(iGroup).numSub

                subID = group(iGroup).subNumber{iSub};

                printProcessingSubject(groupName, iSub, subID);

                % FFX directory and load SPM.mat of that subject
                ffxDir = getFFXdir(subID, funcFWHM, opt);
                load(fullfile(ffxDir, 'SPM.mat'));

                % find which contrast of that subject has the name of the contrast we
                % want to bring to the group level
                conIdx = find(strcmp({SPM.xCon.name}, conName));
                fileName = sprintf('con_%0.4d.nii', conIdx);
                file = inputFileValidation(ffxDir, fileName, smoothPrefix);

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
                                                                fullfile(rfxDir, 'MeanMask.nii')};
        matlabbatch{j}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{j}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{j}.spm.stats.factorial_design.globalm.glonorm = 1;

        % If it exists, issue a warning that it has been overwritten
        if exist(fullfile(rfxDir, conName), 'dir')
            warning('overwriting directory: %s \n', fullfile(rfxDir, conName));
            rmdir(fullfile(rfxDir, conName), 's');
        end

        mkdir(fullfile(rfxDir, conName));
        matlabbatch{j}.spm.stats.factorial_design.dir = { fullfile(rfxDir, conName) };

    end

end
