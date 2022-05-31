function [matlabbatch, contrastsList] = setBatchTwoSampleTTest(varargin)
  %
  % Sets up a group level GLM specification for a 2 sample T test
  %
  % USAGE::
  %
  %   matlabbatch = setBatchTwoSampleTTest(matlabbatch, opt, nodeName)
  %
  %
  % :param matlabbatch: matlabbatch to append to.
  % :type matlabbatch: cell
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % :param nodeName:
  % :type nodeName: char
  %
  %
  % :returns: - :matlabbatch: (cell) The matlabbatch ready to run the spm job
  %
  %
  % Example::
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  args = inputParser;

  addRequired(args, 'matlabbatch', @iscell);
  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'nodeName', @ischar);

  parse(args, varargin{:});

  matlabbatch = args.Results.matlabbatch;
  opt = args.Results.opt;
  nodeName = args.Results.nodeName;

  printBatchName('specify group level paired T-test fmri model', opt);

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  node = opt.model.bm.get_nodes('Name', nodeName);
  if iscell(node)
    node = node{1};
  end

  % Assumes that group belonging was entered like this in the node contrast
  %
  % "ConditionList": [
  %   "Group.blind",
  %   "Group.control"
  % ],
  group1 = regexp(node.Contrasts.ConditionList{1}, '\.', 'split');
  group2 = regexp(node.Contrasts.ConditionList{2}, '\.', 'split');

  % for now we assume we can read the suibject group belonging
  % from the partiticipant TSV in the raw dataset
  % and from the same column
  assert(strcmp(group1{1}, group2{1}));
  groupField = group1{1};

  group1 = group1{2};
  group2 = group2{2};

  availableGroups = unique(BIDS.raw.participants.content.(groupField));

  if any(~ismember({group1, group2}, availableGroups))
    error(['Some requested group is not present: %s.', ...
           '\nAvailable groups in participants.tsv:\n%s'], ...
          strjoin({group1, group2}, ', '), ...
          createUnorderedList(availableGroups));
  end

  % We assume that all the contrast we want to loop over
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
  edge = getEdge(opt.model.bm, 'Destination', nodeName);
  contrastsList = edge.Filter.contrast;

  % collect con images
  for iSub = 1:numel(opt.subjects)
    subLabel = opt.subjects{iSub};
    conImages{iSub} = findSubjectConImage(opt, subLabel, contrastsList);
  end

  % set up the batch
  for iCon = 1:numel(edge.Filter.contrast)

    contrastName = edge.Filter.contrast{iCon};

    rfxDir = getRFXdir(opt, nodeName, contrastName);

    overwriteDir(rfxDir, opt);

    factorialDesign.dir = {rfxDir};
    factorialDesign.des.t2.scans1 = {};
    factorialDesign.des.t2.scans2 = {};

    for iSub = 1:numel(opt.subjects)

      subLabel = opt.subjects{iSub};

      printProcessingSubject(iSub, subLabel, opt);

      idx = strcmp(BIDS.raw.participants.content.participant_id, ['sub-' subLabel]);
      participantGroup = BIDS.raw.participants.content.(groupField){idx};

      if numel(edge.Filter.contrast) == 1
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
              createUnorderedList(availableGroups));
      end

      msg = sprintf(' %s\n\n', file);
      printToScreen(msg, opt);

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

    factorialDesign = setBatchFatorialDesignGlobalCalcAndNorm(factorialDesign);

    matlabbatch{end + 1}.spm.stats.factorial_design = factorialDesign;

    matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                      fullfile(rfxDir, ...
                                               designMatrixFigureName(opt, ...
                                                                      'before estimation')));

  end

end