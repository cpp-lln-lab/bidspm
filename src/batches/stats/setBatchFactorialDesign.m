function [matlabbatch, contrastsList, groups] = setBatchFactorialDesign(matlabbatch, opt, nodeName)
  %
  % Handles group level GLM specification
  %
  % USAGE::
  %
  %   [matlabbatch, contrastsList] = setBatchFactorialDesign(matlabbatch, opt, nodeName)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %
  % :param nodeName:
  % :type nodeName: char
  %
  % :returns: - :matlabbatch: (structure)
  %

  % (C) Copyright 2019 bidspm developers

  % TODO implement other models than group average of contrast from lower levels

  % TODO implement Contrasts and not just dummy contrasts

  % to keep track of all the contrast we used
  % and to which group each batch corresponds to
  % the later is needed to be able to create proper RFX dir name
  contrastsList = {};
  groups = {};

  [status, groupBy] = checks(opt, nodeName);
  if ~status
    return
  end

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  printBatchName(sprintf('specify group level fmri model for node "%s"', nodeName), opt);

  contrasts = getContrastsListForFactorialDesign(opt, nodeName);

  % now we fetch the contrast for each subject and allocate them in the batch
  % - first case is we pool over all subjects
  % - second case is we pool over all the subject of a group defined in the
  %   participants.tsv of the raw dataset
  if all(ismember(lower(groupBy), {'contrast'}))

    % collect all con images from all subjects
    for iSub = 1:numel(opt.subjects)
      subLabel = opt.subjects{iSub};
      conImages{iSub} = findSubjectConImage(opt, subLabel, contrasts);
    end

    % TODO further refactoring is possible?
    for iCon = 1:numel(contrasts)

      contrastName = contrasts{iCon};

      contrastsList{end + 1, 1} = contrastName;
      groups{end + 1, 1} = 'ALL';

      msg = sprintf('\n\n  Group contrast: "%s"\n\n', contrastName);
      printToScreen(msg, opt);

      icell = allocateSubjectsContrasts(opt, opt.subjects, conImages, iCon);

      matlabbatch = assignToBatch(matlabbatch, opt, nodeName, contrastName, icell);

    end

  elseif all(ismember(lower(groupBy), {'contrast', 'group'}))

    groupColumnHdr = groupBy{ismember(lower(groupBy), {'group'})};
    availableGroups = unique(BIDS.raw.participants.content.(groupColumnHdr));

    for iGroup = 1:numel(availableGroups)

      thisGroup = availableGroups{iGroup};

      % grab subjects label from participants.tsv in raw
      % and only keep those that are part of the requested subjects
      %
      % Note that this will lead to different results depending on the requested
      % subejcts
      %
      tsv = BIDS.raw.participants.content;
      subjectsInGroup = strcmp(tsv.(groupColumnHdr), thisGroup);
      subjectsLabel = regexprep(tsv.participant_id(subjectsInGroup), '^sub-', '');
      subjectsLabel = intersect(subjectsLabel, opt.subjects);

      % collect all con images from all subjects
      for iSub = 1:numel(subjectsLabel)
        subLabel = subjectsLabel{iSub};
        conImages{iSub} = findSubjectConImage(opt, subLabel, contrasts);
      end

      for iCon = 1:numel(contrasts)

        contrastName = contrasts{iCon};

        contrastsList{end + 1, 1} = contrastName;
        groups{end + 1, 1} = thisGroup;

        msg = sprintf('\n\n  Group contrast "%s" for group "%s"\n\n', contrastName, thisGroup);
        printToScreen(msg, opt);

        icell = allocateSubjectsContrasts(opt, subjectsLabel, conImages, iCon);

        matlabbatch = assignToBatch(matlabbatch, opt, nodeName, contrastName, icell, thisGroup);

      end

    end

  end
end

function icell = allocateSubjectsContrasts(opt, subjectsLabel, conImages, iCon)

  icell(1).scans = {};

  for iSub = 1:numel(subjectsLabel)

    subLabel = subjectsLabel{iSub};

    % TODO refactor with setBatchTwoSampleTTest ?
    if ischar(conImages{iSub})
      file = conImages{iSub};
    elseif iscell(conImages{iSub})
      file = conImages{iSub}{iCon};
    end
    if isempty(file)
      continue
    end

    icell(1).scans{end + 1, 1} = file;

    printProcessingSubject(iSub, subLabel, opt);
    msg = sprintf(' %s\n\n', pathToPrint(char(file)));
    printToScreen(msg, opt);

  end

end

function matlabbatch = assignToBatch(matlabbatch, opt, nodeName, contrastName, icell, thisGroup)

  if nargin == 5
    thisGroup = '';
  end
  rfxDir = getRFXdir(opt, nodeName, contrastName, thisGroup);
  overwriteDir(rfxDir, opt);

  assert(exist(fullfile(rfxDir, 'SPM.mat'), 'file') == 0);

  icell(1).levels = 1;

  assert(isstring(icell.scans));

  matlabbatch = returnFactorialDesignBatch(matlabbatch, rfxDir, icell, thisGroup);

  mask = getInclusiveMask(opt, nodeName);
  matlabbatch{end}.spm.stats.factorial_design.masking.em = {mask};

  matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                    fullfile(rfxDir, ...
                                             designMatrixFigureName(opt, ...
                                                                    'before estimation')));
end

function matlabbatch = returnFactorialDesignBatch(matlabbatch, directory, icell, thisGroup)

  if isempty(thisGroup)
    thisGroup = 'GROUP';
  end

  factorialDesign.dir = {directory};

  factorialDesign.des.fd.icell = icell;

  % GROUP and the number of levels in the group.
  % If 2 groups, then number of levels = 2
  factorialDesign.des.fd.fact.name = thisGroup;
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
