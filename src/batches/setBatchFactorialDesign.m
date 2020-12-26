% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchFactorialDesign(matlabbatch, group, grpLvlCon, conFWHM, rfxDir)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchFactorialDesign(matlabbatch, group, grpLvlCon, conFWHM, rfxDir)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param group:
  % :type group: structure
  % :param grpLvlCon:
  % :type grpLvlCon:
  % :param conFWHM:
  % :type conFWHM:
  % :param rfxDir:
  % :type rfxDir:
  %
  % :returns: - :matlabbatch: (structure)
  %

  printBatchName('specify group level fmri model');

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

    % If it exists, issue a warning that it has been overwritten
    if exist(fullfile(rfxDir, conName), 'dir')
      warning('overwriting directory: %s \n', fullfile(rfxDir, conName));
      rmdir(fullfile(rfxDir, conName), 's');
    end

    mkdir(fullfile(rfxDir, conName));
    matlabbatch{end + 1}.spm.stats.factorial_design.dir = { fullfile(rfxDir, conName) };

    con = con + 1;

    % For each group
    for iGroup = 1:length(group)

      groupName = group(iGroup).name;

      matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(iGroup).levels = ...
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
        file = validationInputFile(ffxDir, fileName, smoothPrefix);

        matlabbatch{end}.spm.stats.factorial_design.des.fd.icell(iGroup).scans(iSub, :) = ...
            {file};

      end

    end

    % GROUP and the number of levels in the group. if 2 groups ,
    % then number of levels = 2
    matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.name = 'GROUP';
    matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.levels = 1;
    matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.dept = 0;

    % 1: Assumes that the variance is not the same across groups
    % 0: There is no difference in the variance between groups
    matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.variance = 1;
    matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.gmsca = 0;
    matlabbatch{end}.spm.stats.factorial_design.des.fd.fact.ancova = 0;
    % matlabbatch{end}.spm.stats.factorial_design.cov = [];
    matlabbatch{end}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{end}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{end}.spm.stats.factorial_design.masking.em = { ...
                                                              fullfile(rfxDir, 'MeanMask.nii')};
    matlabbatch{end}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{end}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{end}.spm.stats.factorial_design.globalm.glonorm = 1;

  end

end
