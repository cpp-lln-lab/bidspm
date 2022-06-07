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

  [status, groupBy] = checks(opt, nodeName);
  if ~status
    return
  end

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  printBatchName('specify group level fmri model', opt);

  % average at the group level
  if opt.model.bm.get_design_matrix('Name', nodeName) == 1

    % assuming a GroupBy that contains at least "contrast"
    % we try to grab the contrasts list from the Edge.Filter
    % otherwise we dig in this in Node
    % or the previous one to find the list of contrasts
    edge = opt.model.bm.get_edge('Destination', nodeName);

    if isfield(edge, 'Filter') && ...
        isfield(edge.Filter, 'contrast')  && ...
        ~isempty(edge.Filter.contrast)

      contrastsList = edge.Filter.contrast;

    else

      % this assumes DummyContrasts exist
      contrastsList = getDummyContrastsList(nodeName, opt.model.bm);

      node = opt.model.bm.get_nodes('Name', nodeName);

      % if no specific dummy contrasts mentionned also include all contrasts from previous levels
      % or if contrasts are mentionned we grab them
      if ~isfield(node.DummyContrasts, 'Contrasts') || isfield(node, 'Contrasts')
        tmp = getContrastsList(nodeName, opt.model.bm);
        for i = 1:numel(tmp)
          contrastsList{end + 1} = tmp{i}.Name;
        end
      end

    end

  else

    commonMsg = sprintf('for the dataset level node: "%s"', nodeName);
    msg = sprintf('Models other than group average not implemented yet %s', commonMsg);
    notImplemented(mfilename(), msg, opt.verbosity);

  end

  if all(ismember(lower(groupBy), {'contrast'}))

    for j = 1:numel(contrastsList)

      contrastName = contrastsList{j};

      msg = sprintf('\n\n  Group contrast: %s\n\n', contrastName);
      printToScreen(msg, opt);

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

      rfxDir = getRFXdir(opt, nodeName, contrastName);
      overwriteDir(rfxDir, opt);

      matlabbatch = returnFactorialDesignBatch(matlabbatch, rfxDir, icell);

      mask = getInclusiveMask(opt, nodeName);
      matlabbatch{end}.spm.stats.factorial_design.masking.em = {mask};

      matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                        fullfile(rfxDir, ...
                                                 designMatrixFigureName(opt, ...
                                                                        'before estimation')));

    end

  elseif all(ismember(lower(groupBy), {'contrast', 'group'}))

    groupColumnHdr = groupBy{ismember(lower(groupBy), {'group'})};
    availableGroups = unique(BIDS.raw.participants.content.(groupColumnHdr));

    for iGroup = 1:numel(availableGroups)

      thisGroup = availableGroups{iGroup};

      % grab subjects label from participants.tsv in raw
      subjectsInGroup = strcmp(BIDS.raw.participants.content.(groupColumnHdr), thisGroup);
      subjectsInGroup = BIDS.raw.participants.content.participant_id(subjectsInGroup);
      subjectsLabel = regexprep(subjectsInGroup, '^sub-', '');

      % collect all con images from all subjects
      for iSub = 1:numel(subjectsLabel)
        subLabel = subjectsLabel{iSub};
        conImages{iSub} = findSubjectConImage(opt, subLabel, contrastsList);
      end

      for j = 1:numel(contrastsList)

        contrastName = contrastsList{j};

        msg = sprintf('\n\n  Group contrast "%s" for group "%s"\n\n', contrastName, thisGroup);
        printToScreen(msg, opt);

        icell(1).levels = 1; %#ok<*AGROW>

        for iSub = 1:numel(subjectsLabel)

          subLabel = subjectsLabel{iSub};
          printProcessingSubject(iSub, subLabel, opt);

          % TODO refactor with setBatchTwoSampleTTest ?
          if numel(edge.Filter.contrast) == 1
            file = conImages{iSub};
          else
            file = conImages{iSub}{iCon};
          end
          if isempty(file)
            continue
          end

          icell(1).scans{iSub, 1} = file;

          msg = sprintf(' %s\n\n', conImages{iSub});
          printToScreen(msg, opt);

        end

        rfxDir = getRFXdir(opt, [nodeName ' group ' thisGroup], contrastName);
        overwriteDir(rfxDir, opt);

        matlabbatch = returnFactorialDesignBatch(matlabbatch, rfxDir, icell);

        clear icell;

        mask = getInclusiveMask(opt, nodeName);
        matlabbatch{end}.spm.stats.factorial_design.masking.em = {mask};

        matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                          fullfile(rfxDir, ...
                                                   designMatrixFigureName(opt, ...
                                                                          'before estimation')));

      end

    end

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

function [status, groupBy] = checks(opt, nodeName)

  thisNode = opt.model.bm.get_nodes('Name', nodeName);

  commonMsg = sprintf('for the dataset level node: "%s"', nodeName);

  [status, groupBy] = checkGroupBy(thisNode);

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
