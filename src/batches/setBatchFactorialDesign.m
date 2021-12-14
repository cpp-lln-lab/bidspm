function matlabbatch = setBatchFactorialDesign(matlabbatch, opt)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchFactorialDesign(matlabbatch, opt, funcFWHM, conFWHM)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param opt:
  % :type opt: structure
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2019 CPP_SPM developers

  printBatchName('specify group level fmri model', opt);

  % Check which level of CON smoothing is desired
  smoothPrefix = '';
  if opt.fwhm.contrast > 0
    smoothPrefix = ['s', num2str(opt.fwhm.contrast)];
  end

  [~, opt] = getData(opt, opt.dir.preproc);

  rfxDir = getRFXdir(opt);

  grpLvlCon = getGrpLevelContrast(opt);

  % For each contrast
  for j = 1:size(grpLvlCon, 1)

    % the strrep(Session{j}, 'trial_type.', '') is there to remove
    % 'trial_type.' because contrasts against baseline are renamed
    % at the subject level
    conName = rmTrialTypeStr(grpLvlCon.Contrasts{j});

    msg = sprintf('\n\n  Group contrast: %s\n\n', conName);
    printToScreen(msg, opt);

    directory = fullfile(rfxDir, conName);

    overwriteDir(directory, opt);

    icell(1).levels = 1; %#ok<*AGROW>

    for iSub = 1:numel(opt.subjects)

      subLabel = opt.subjects{iSub};

      printProcessingSubject(iSub, subLabel, opt);

      % FFX directory and load SPM.mat of that subject
      ffxDir = getFFXdir(subLabel, opt);
      load(fullfile(ffxDir, 'SPM.mat'));

      % find which contrast of that subject has the name of the contrast we
      % want to bring to the group level
      conIdx = find(strcmp({SPM.xCon.name}, conName));
      if isempty(conIdx)
        disp({SPM.xCon.name}');
        msg = sprintf('Could not find a contrast named %s\nin %s.\n', ...
                      conName, ...
                      fullfile(ffxDir, 'SPM.mat'));
        errorHandling(mfilename(), 'missingContrast', msg, false, opt.verbosity);
      end
      fileName = sprintf('con_%0.4d.nii', conIdx);
      file = validationInputFile(ffxDir, fileName, smoothPrefix);

      icell(1).scans(iSub, :) = {file};

      msg = sprintf(' %s\n\n', file);
      printToScreen(msg, opt);

    end

    matlabbatch = returnFactorialDesignBatch(matlabbatch, directory, icell);

  end

end

function matlabbatch = returnFactorialDesignBatch(matlabbatch, directory, icell)

  matlabbatch{end + 1}.spm.stats.factorial_design.dir = {directory};

  matlabbatch{end}.spm.stats.factorial_design.des.fd.icell = icell;

  % GROUP and the number of levels in the group.
  % If 2 groups, then number of levels = 2
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
  matlabbatch{end}.spm.stats.factorial_design.masking.em = {''};
  matlabbatch{end}.spm.stats.factorial_design.globalc.g_omit = 1;
  matlabbatch{end}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
  matlabbatch{end}.spm.stats.factorial_design.globalm.glonorm = 1;

end
