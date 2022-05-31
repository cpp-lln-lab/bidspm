function [matlabbatch, contrastsList] = setBatchFactorialDesign(matlabbatch, opt, nodeName)
  %
  % Handles group level GLM specification
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
  % :param nodeName:
  % :type nodeName: char
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

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  printBatchName('specify group level fmri model', opt);

  % average at the group level
  if opt.model.bm.get_design_matrix('Name', nodeName) == 1

    % assumes DummyContrasts exist
    contrastsList = getDummyContrastsList(nodeName, opt.model.bm);

    node = opt.model.bm.get_nodes('Name', nodeName);
    if iscell(node)
      node = node{1};
    end

    % no specific dummy contrasts mentionned also include all contrasts from previous levels
    % contrast are mentionned we grab them
    if ~isfield(node.DummyContrasts, 'Contrasts') || isfield(node, 'Contrasts')
      tmp = getContrastsList(nodeName, opt.model.bm);
      for i = 1:numel(tmp)
        contrastsList{end + 1} = tmp{i}.Name;
      end
    end

  end

  % For each contrast
  for j = 1:numel(contrastsList)

    contrastName = contrastsList{j};

    msg = sprintf('\n\n  Group contrast: %s\n\n', contrastName);
    printToScreen(msg, opt);

    rfxDir = getRFXdir(opt, nodeName, contrastName);

    overwriteDir(rfxDir, opt);

    icell(1).levels = 1; %#ok<*AGROW>

    for iSub = 1:numel(opt.subjects)

      subLabel = opt.subjects{iSub};

      printProcessingSubject(iSub, subLabel, opt);

      file = findSubjectConImage(opt, subLabel, contrastName);
      if isempty(file)
        continue
      end

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

  factorialDesign.dir = {directory};

  factorialDesign.des.fd.icell = icell;

  % GROUP and the number of levels in the group.
  % If 2 groups, then number of levels = 2
  factorialDesign.des.fd.fact.name = 'GROUP';
  factorialDesign.des.fd.fact.levels = numel(icell);
  factorialDesign.des.fd.fact.dept = 0;

  % 1: Assumes that the variance is not the same across groups
  % 0: There is no difference in the variance between groups
  factorialDesign.des.fd.fact.variance = 1;
  factorialDesign.des.fd.fact.gmsca = 0;
  factorialDesign.des.fd.fact.ancova = 0;
  % factorial_design.cov = [];

  factorialDesign = setBatchFactorialDesignImplicitMasking(factorialDesign);

  factorialDesign = setBatchFatorialDesignGlobalCalcAndNorm(factorialDesign);

  matlabbatch{end + 1}.spm.stats.factorial_design = factorialDesign;

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
