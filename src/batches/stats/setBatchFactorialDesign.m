function matlabbatch = setBatchFactorialDesign(matlabbatch, opt, nodeName)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchFactorialDesign(matlabbatch, opt, nodeName)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  %
  % :param opt:
  % :type opt: structure
  %
  % nodeName
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2019 CPP_SPM developers

  % TODO implement other models than group average of contrast from lower levels
  % TODO implement Contrasts and not just dummy contrasts

  status = checks(opt, nodeName);
  if ~status
    return
  end

  printBatchName('specify group level fmri model', opt);

  % Check which level of CON smoothing is desired
  smoothPrefix = '';
  if opt.fwhm.contrast > 0
    smoothPrefix = ['s', num2str(opt.fwhm.contrast)];
  end

  [~, opt] = getData(opt, opt.dir.preproc);

  % average at the group level
  if opt.model.bm.get_design_matrix('Name', nodeName) == 1

    dummyContrastsList = getDummyContrastsList(nodeName, opt.model.bm);

  end

  % For each contrast
  for j = 1:numel(dummyContrastsList)

    contrastName = dummyContrastsList{j};

    msg = sprintf('\n\n  Group contrast: %s\n\n', contrastName);
    printToScreen(msg, opt);

    rfxDir = getRFXdir(opt, nodeName, contrastName);

    overwriteDir(rfxDir, opt);

    icell(1).levels = 1; %#ok<*AGROW>

    for iSub = 1:numel(opt.subjects)

      subLabel = opt.subjects{iSub};

      printProcessingSubject(iSub, subLabel, opt);

      % FFX directory and load SPM.mat of that subject
      ffxDir = getFFXdir(subLabel, opt);
      load(fullfile(ffxDir, 'SPM.mat'));

      % find which contrast of that subject has the name of the contrast we
      % want to bring to the group level
      conIdx = find(strcmp({SPM.xCon.name}, contrastName));
      if isempty(conIdx)
        disp({SPM.xCon.name}');
        msg = sprintf('Skipping subject %s. Could not find a contrast named %s\nin %s.\n', ...
                      subLabel, ...
                      contrastName, ...
                      fullfile(ffxDir, 'SPM.mat'));
        errorHandling(mfilename(), 'missingContrast', msg, true, opt.verbosity);
        continue
      end
      fileName = sprintf('con_%0.4d.nii', conIdx);
      file = validationInputFile(ffxDir, fileName, smoothPrefix);

      icell(1).scans(iSub, :) = {file};

      msg = sprintf(' %s\n\n', file);
      printToScreen(msg, opt);

    end

    matlabbatch = returnFactorialDesignBatch(matlabbatch, rfxDir, icell);

    mask = getInclusiveMask(opt, nodeName);
    matlabbatch{end}.spm.stats.factorial_design.masking.em = {mask};

    matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                      fullfile(rfxDir, ...
                                               designMatrixFigureName(opt, ...
                                                                      'before estimation')));

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

function status = checks(opt, nodeName)

  thisNode = opt.model.bm.get_nodes('Name', nodeName);
  if iscell(thisNode)
    thisNode = thisNode{1};
  end

  commonMsg = sprintf('for the dataset level node: "%s"', nodeName);

  status = checkGroupBy(thisNode);

  % only certain type of model supported for now
  designMatrix = opt.model.bm.get_design_matrix('Name', nodeName);
  if iscell(designMatrix) || (designMatrix ~= 1)

    msg = sprintf('Models other than group average not implemented yet %s', commonMsg);
    notImplemented(mfilename(), msg, opt.verbosity);

    status = false;

  end

  datasetLvlDummyContrasts = opt.model.bm.get_dummy_contrasts('Name', nodeName);
  if isempty(datasetLvlDummyContrasts) || ~isfield(datasetLvlDummyContrasts, 'Test')

    msg = sprintf('Only DummyContrasts are implemented %s', commonMsg);
    notImplemented(mfilename(), msg, opt.verbosity);

    status = false;

  end

  datasetLvlContrasts = opt.model.bm.get_contrasts('Name', nodeName);
  if ~isempty(datasetLvlContrasts)

    msg = sprintf('Contrasts are not yet implemented %s', commonMsg);
    notImplemented(mfilename(), msg, opt.verbosity);

  end

end
