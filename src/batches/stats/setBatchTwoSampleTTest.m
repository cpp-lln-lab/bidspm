function [matlabbatch, contrastsList, groupList] = setBatchTwoSampleTTest(varargin)
  %
  % Sets up a group level GLM specification for a 2 sample T test
  %
  % USAGE::
  %
  %   matlabbatch = setBatchTwoSampleTTest(matlabbatch, opt, nodeName)
  %
  %
  % :param matlabbatch: matlabbatch to append to.
  % :type  matlabbatch: cell
  %
  % :type  opt: structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :param nodeName:
  % :type  nodeName: char
  %
  % :return: :matlabbatch: (cell) The matlabbatch ready to run the spm job
  %

  % (C) Copyright 2022 bidspm developers

  % TODO so far this assumes contrasts are only passed through Edge.Filter
  %      this is too restrictive
  %      could want to do 2 sample t-tests on all contrast from lower levels

  args = inputParser;

  addRequired(args, 'matlabbatch', @iscell);
  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'nodeName', @ischar);

  parse(args, varargin{:});

  matlabbatch = args.Results.matlabbatch;
  opt = args.Results.opt;
  nodeName = args.Results.nodeName;

  %%
  groupList = {};

  %%
  printBatchName('specify group level paired T-test fmri model', opt);

  [~, opt] = getData(opt, opt.dir.preproc);

  node = opt.model.bm.get_nodes('Name', nodeName);

  % Assumes that group belonging was entered like this in the node contrast
  %
  % "ConditionList": [
  %   "Group.blind",
  %   "Group.control"
  % ],
  group1 = regexp(node.Contrasts{1}.ConditionList{1}, '\.', 'split');
  group2 = regexp(node.Contrasts{1}.ConditionList{2}, '\.', 'split');

  % for now we assume we can read the subject group belonging
  % from the participant TSV in the raw dataset
  % and from the same column
  assert(strcmp(group1{1}, group2{1}));
  groupField = group1{1};

  group1 = group1{2};
  group2 = group2{2};

  % TODO refactor
  availableGroups = getAvailableGroups(opt, groupField);
  participants = bids.util.tsvread(fullfile(opt.dir.raw, 'participants.tsv'));

  if any(~ismember({group1, group2}, availableGroups))
    error(['Some requested group is not present: %s.', ...
           '\nAvailable groups in participants.tsv:\n%s'], ...
          strjoin({group1, group2}, ', '), ...
          bids.internal.create_unordered_list(availableGroups));
  end

  contrastsList = getContrastsListForDatasetLevel(opt, nodeName);

  % collect con images
  for iSub = 1:numel(opt.subjects)
    subLabel = opt.subjects{iSub};
    conImages{iSub} = findSubjectConImage(opt, subLabel, contrastsList);
  end

  % set up the batch
  for iCon = 1:numel(contrastsList)

    groupList{end + 1, 1} = 'ALL';

    contrastName = contrastsList{iCon};

    rfxDir = getRFXdir(opt, nodeName, contrastName, groupList{end});

    overwriteDir(rfxDir, opt);

    factorialDesign.dir = {rfxDir};
    factorialDesign.des.t2.scans1 = {};
    factorialDesign.des.t2.scans2 = {};

    for iSub = 1:numel(opt.subjects)

      subLabel = opt.subjects{iSub};

      idx = strcmp(participants.participant_id, ['sub-' subLabel]);
      participantGroup = participants.(groupField){idx};

      if numel(contrastsList) == 1
        file = conImages{iSub};
      else
        file = conImages{iSub}{iCon};
      end
      if isempty(file)
        continue
      end

      if strcmp (participantGroup, group1)
        factorialDesign.des.t2.scans1{end + 1, 1} = file;

      elseif strcmp (participantGroup, group2)
        factorialDesign.des.t2.scans2{end + 1, 1} = file;

      else
        error(['Unknown group: %s.', ...
               '\nAvailable groups in participants.tsv:\n%s'], ...
              participantGroup, ...
              bids.internal.create_unordered_list(availableGroups));
      end

      printProcessingSubject(iSub, subLabel, opt);
      msg = sprintf(' %s', file);
      logger('INFO', msg, 'options', opt, 'filename', mfilename());

    end

    mask = getInclusiveMask(opt, nodeName);
    factorialDesign.masking.em = {mask};

    factorialDesign.des.t2.dept = 0;
    factorialDesign.des.t2.variance = 1;
    factorialDesign.des.t2.gmsca = 0;
    factorialDesign.des.t2.ancova = 0;

    factorialDesign.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    factorialDesign.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});

    factorialDesign = setBatchFactorialDesignImplicitMasking(factorialDesign);

    factorialDesign = setBatchFactorialDesignGlobalCalcAndNorm(factorialDesign);

    matlabbatch{end + 1}.spm.stats.factorial_design = factorialDesign;

    matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                      fullfile(rfxDir, ...
                                               designMatrixFigureName(opt, ...
                                                                      'before estimation')));

  end

end

function contrastsList = getContrastsListForDatasetLevel(opt, nodeName)

  % TODO refactor with "getContrastsListForFactorialDesign" from
  % "setBatchFactorialDesign"

  contrastsList = {};

  % we try to grab the contrasts list from the Edge.Filter
  % otherwise we dig in this in Node
  % or the previous one to find the list of contrasts

  % If we assume that all the contrast we want to loop over
  % are specified in the Filter of the edge of the BIDS stats model
  %
  % {
  %   "Source": "subject_level",
  %   "Destination": "between_groups",
  %   "Filter": {
  %     "contrast": [
  %       "bar", "foo"
  %     ]
  %   }
  % }

  edge = opt.model.bm.get_edge('Destination', nodeName);

  if isfield(edge, 'Filter') && ...
      isfield(edge.Filter, 'contrast')  && ...
      ~isempty(edge.Filter.contrast)

    contrastsList = edge.Filter.contrast;

  else

    % TODO?? can't imagine a 2 sample t-test with dummy contrasts
    node = opt.model.bm.get_nodes('Name', nodeName);

    % if no specific dummy contrasts mentioned also include all contrasts from previous levels
    % or if contrasts are mentioned we grab them
    if isfield(node, 'Contrasts')
      tmp = getContrastsList(opt.model.bm, nodeName);
      for i = 1:numel(tmp)
        contrastsList{end + 1} = tmp{i}.Name;
      end
    end

  end

end
