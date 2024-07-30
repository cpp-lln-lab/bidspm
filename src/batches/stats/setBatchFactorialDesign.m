function [matlabbatch, contrastsList, groups] = setBatchFactorialDesign(matlabbatch, opt, nodeName)
  %
  % Handles group level GLM specification
  %
  % USAGE::
  %
  %   [matlabbatch, contrastsList] = setBatchFactorialDesign(matlabbatch, opt, nodeName)
  %
  % :param matlabbatch:
  % :type  matlabbatch: structure
  %
  % :type  opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :param nodeName:
  % :type  nodeName: char
  %
  % :return: matlabbatch
  % :rtype: structure

  % (C) Copyright 2019 bidspm developers

  % to keep track of all the contrast we used
  % and to which group each batch corresponds to
  % the later is needed to be able to create proper RFX dir name
  contrastsList = {};
  groups = {};

  [status, groupBy, glmType] = checks(opt, nodeName);
  if ~status
    return
  end

  printBatchName(sprintf('specify group level fmri model for node "%s"', nodeName), opt);

  % now we fetch the contrast for each subject and allocate them in the batch
  % - first case is we pool over all subjects
  % - second case is we pool over all the subject of a group defined in the
  %   participants.tsv of the raw dataset
  switch glmType
    case 'one_sample_t_test'

      if numel(groupBy) == 1 && strcmpi(groupBy, {'contrast'})
        [matlabbatch, contrastsList, groups] = tTestAcrossSubject(matlabbatch, opt, nodeName);
      elseif numel(groupBy) == 2
        [matlabbatch, contrastsList, groups] = tTestForGroup(matlabbatch, opt, nodeName);
      end

    case  {'two_sample_t_test', 'one_way_anova'}

      if strcmp(glmType, 'two_sample_t_test')
        label = '2samplesTTest';
      else
        label = '1WayANOVA';
      end

      contrastsList = getContrastsListForFactorialDesign(opt, nodeName);

      % Sorting is important so that we know in which order
      % the groups are entered in the design matrix.
      % Otherwise it will be harder to properly design
      % the contrast vectors later.
      groupColumnHdr = opt.model.bm.getGroupColumnHdrFromDesignMatrix(nodeName);
      availableGroups = getAvailableGroups(opt, groupColumnHdr);

      if strcmp(glmType, 'two_sample_t_test') && numel(availableGroups) > 2
        list = bids.internal.create_unordered_list(availableGroups);
        msg = sprintf('Too many groups for 2 samples t-test: "%s"', list);
        logger('ERROR', msg, 'options', opt, 'filename', filename, 'id', id);
      end

      for iCon = 1:numel(contrastsList)

        groups{end + 1} = label; %#ok<*AGROW>

        contrastName = contrastsList{iCon};

        rfxDir = getRFXdir(opt, nodeName, contrastName, label);
        overwriteDir(rfxDir, opt);

        assert(~checkSpmMat(rfxDir, opt));

        if strcmp(glmType, 'two_sample_t_test')
          factorialDesign = returnTwoSampleTTestBatch(rfxDir);
        else
          factorialDesign = returnOneWayAnovaBatch(rfxDir);
        end

        for iGroup = 1:numel(availableGroups)

          thisGroup = availableGroups{iGroup};

          subjectsLabel = returnSubjectLabelInGroup(opt, groupColumnHdr, thisGroup);

          % collect all con images from all subjects
          for iSub = 1:numel(subjectsLabel)
            subLabel = subjectsLabel{iSub};
            conImages{iSub} = findSubjectConImage(opt, subLabel,  contrastName);
          end

          msg = sprintf('  Group contrast "%s" for group "%s"', contrastName, thisGroup);
          logger('INFO', msg, 'options', opt, 'filename', mfilename());

          icell = allocateSubjectsConImages(opt, subjectsLabel, conImages, iCon);

          if strcmp(glmType, 'two_sample_t_test')
            if iGroup == 1
              factorialDesign.des.t2.scans1 = icell.scans;

            elseif iGroup == 2
              factorialDesign.des.t2.scans2 = icell.scans;
            end
          elseif strcmp(glmType, 'one_way_anova')
            factorialDesign.des.anova.icell(iGroup).scans = icell.scans;
          end

        end

        mask = getInclusiveMask(opt, nodeName);
        factorialDesign.masking.em = {mask};

        matlabbatch{end + 1}.spm.stats.factorial_design = factorialDesign;

        matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                          fullfile(rfxDir, ...
                                                   designMatrixFigureName(opt, ...
                                                                          'before estimation')));

      end

  end
end

function [matlabbatch, contrastsList, groups] = tTestAcrossSubject(matlabbatch, opt, nodeName)

  % to keep track of all the contrast we used
  % and to which group each batch corresponds to
  % the later is needed to be able to create proper RFX dir name
  contrastsList = {};
  groups = {};

  contrasts = getContrastsListForFactorialDesign(opt, nodeName);

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

    msg = sprintf('  Group contrast: "%s"', contrastName);
    logger('INFO', msg, 'options', opt, 'filename', mfilename());

    icell = allocateSubjectsConImages(opt, opt.subjects, conImages, iCon);

    matlabbatch = assignToBatch(matlabbatch, opt, nodeName, contrastName, icell);

  end
end

function [matlabbatch, contrastsList, groups] = tTestForGroup(matlabbatch, opt, nodeName)

  % to keep track of all the contrast we used
  % and to which group each batch corresponds to
  % the later is needed to be able to create proper RFX dir name
  contrastsList = {};
  groups = {};

  contrasts = getContrastsListForFactorialDesign(opt, nodeName);

  participants = bids.util.tsvread(fullfile(opt.dir.raw, 'participants.tsv'));
  groupColumnHdr = opt.model.bm.getGroupColumnHdrFromGroupBy(nodeName, participants);
  availableGroups = getAvailableGroups(opt, groupColumnHdr);

  for iGroup = 1:numel(availableGroups)

    thisGroup = availableGroups{iGroup};
    subjectsLabel = returnSubjectLabelInGroup(opt, groupColumnHdr, thisGroup);

    % collect all con images from all subjects
    for iSub = 1:numel(subjectsLabel)
      subLabel = subjectsLabel{iSub};
      conImages{iSub} = findSubjectConImage(opt, subLabel, contrasts);
    end

    for iCon = 1:numel(contrasts)

      contrastName = contrasts{iCon};

      contrastsList{end + 1, 1} = contrastName;
      groups{end + 1, 1} = thisGroup;

      msg = sprintf('  Group contrast "%s" for group "%s"', contrastName, thisGroup);
      logger('INFO', msg, 'options', opt, 'filename', mfilename());

      icell = allocateSubjectsConImages(opt, subjectsLabel, conImages, iCon);

      matlabbatch = assignToBatch(matlabbatch, opt, nodeName, contrastName, icell, thisGroup);

    end

  end

end

function subjectsLabel = returnSubjectLabelInGroup(opt, groupColumnHdr, group)
  % grab subjects label from participants.tsv in raw
  % and only keep those that are part of the requested subjects
  %
  % Note that this will lead to different results depending on the requested subejcts
  %
  participants = bids.util.tsvread(fullfile(opt.dir.raw, 'participants.tsv'));
  subjectsInGroup = strcmp(participants.(groupColumnHdr), group);
  subjectsLabel = regexprep(participants.participant_id(subjectsInGroup), '^sub-', '');
  subjectsLabel = intersect(subjectsLabel, opt.subjects);
end

function icell = allocateSubjectsConImages(opt, subjectsLabel, conImages, iCon)

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
    msg = sprintf(' %s', bids.internal.format_path(char(file)));
    logger('INFO', msg, 'options', opt, 'filename', mfilename());

  end

end

function matlabbatch = assignToBatch(matlabbatch, opt, nodeName, contrastName, icell, thisGroup)

  if nargin == 5
    thisGroup = '';
  end
  rfxDir = getRFXdir(opt, nodeName, contrastName, thisGroup);
  overwriteDir(rfxDir, opt);

  opt.verbosity = 0;
  assert(~checkSpmMat(rfxDir, opt));

  icell(1).levels = 1;

  assert(iscellstr(icell.scans));

  factorialDesign = returnFactorialDesignBatch(rfxDir, icell, thisGroup);

  matlabbatch{end + 1}.spm.stats.factorial_design = factorialDesign;

  mask = getInclusiveMask(opt, nodeName);
  matlabbatch{end}.spm.stats.factorial_design.masking.em = {mask};

  matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                    fullfile(rfxDir, ...
                                             designMatrixFigureName(opt, ...
                                                                    'before estimation')));
end

function factorialDesign = returnFactorialDesignBatch(directory, icell, thisGroup)
  if isempty(thisGroup)
    thisGroup = 'GROUP';
  end

  factorialDesign = commonFactorialDesignBatch(directory);

  factorialDesign.des.fd.icell = icell;

  factorialDesign.des.fd.fact = varianceStruct();

  % GROUP and the number of levels in the group.
  % If 2 groups, then number of levels = 2
  factorialDesign.des.fd.fact.name = thisGroup;
  factorialDesign.des.fd.fact.levels = numel(icell);
end

function factorialDesign = returnTwoSampleTTestBatch(directory)
  factorialDesign = commonFactorialDesignBatch(directory);

  factorialDesign.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
  factorialDesign.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});

  factorialDesign.des.t2 = varianceStruct();

  factorialDesign.des.t2.scans1 = {};
  factorialDesign.des.t2.scans2 = {};
end

function factorialDesign = returnOneWayAnovaBatch(directory)
  factorialDesign = commonFactorialDesignBatch(directory);

  factorialDesign.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
  factorialDesign.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});

  factorialDesign.des.anova = varianceStruct();

  factorialDesign.des.anova.icell(1).scans = {};
end

function factorialDesign = commonFactorialDesignBatch(directory)
  factorialDesign.dir = {directory};
  factorialDesign = setBatchFactorialDesignImplicitMasking(factorialDesign);
  factorialDesign = setBatchFactorialDesignGlobalCalcAndNorm(factorialDesign);
end

function value = varianceStruct()

  value = struct();

  % Assumes groups are independent
  value(1).dept = 0;
  % 1: Assumes that the variance is not the same across groups
  % 0: There is no difference in the variance between groups
  value.variance = 1;
  value.gmsca = 0;
  value.ancova = 0;

end

function [status, groupBy, glmType] = checks(opt, nodeName)

  commonMsg = sprintf('for the dataset level node: "%s"', nodeName);

  % TODO refactor
  participants = bids.util.tsvread(fullfile(opt.dir.raw, 'participants.tsv'));

  bm = opt.model.bm;

  status = bm.validateGroupBy(nodeName, participants);

  [glmType, groupBy] = bm.groupLevelGlmType(nodeName, participants);

  % only certain type of model supported for now
  if ismember(glmType, {'unknown'})
    % TODO update message to with better info for 2 sample T-Test
    msg = sprintf(['Models other than group average / comparisons ', ...
                   'not implemented yet %s'], commonMsg);
    notImplemented(mfilename(), msg, opt);
    status = false;
    return
  end

  datasetLvlContrasts = bm.get_contrasts('Name', nodeName);
  datasetLvlDummyContrasts = bm.get_dummy_contrasts('Name', nodeName);

  if ismember(glmType, {'one_sample_t_test'}) && ...
    (not(isempty(datasetLvlContrasts)) || isempty(datasetLvlDummyContrasts))
    msg = sprintf('For one-sample t-test only DummyContrasts are implemented %s', commonMsg);
    notImplemented(mfilename(), msg, opt);
  end

  if ismember(glmType, {'one_way_anova', 'two_sample_t_test'}) && ...
          (isempty(datasetLvlContrasts) || not(isempty(datasetLvlDummyContrasts)))
    msg = sprintf(['For one-way ANOVA or 2 samples t-test ', ...
                   'only contrasts are implemented %s'], commonMsg);
    notImplemented(mfilename(), msg, opt);
  end

end
