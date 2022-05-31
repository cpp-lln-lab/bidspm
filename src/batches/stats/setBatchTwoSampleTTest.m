function matlabbatch = setBatchTwoSampleTTest(varargin)
  %
  % Short batch description
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

  matlabbatch =    args.Results.matlabbatch;
  opt =    args.Results.opt;
  nodeName =    args.Results.nodeName;

  printBatchName('specify group level paired T-test fmri model', opt);

  node = opt.model.bm.get_nodes('Name', nodeName);
  if iscell(node)
    node = node{1};
  end

  group1 = strrep(node.Contrasts.ConditionList{1}, 'group.', '');
  group2 = strrep(node.Contrasts.ConditionList{2}, 'group.', '');

  edge = getEdge(opt.model.bm, 'Destination', nodeName);

  contrastName = edge.Filter.contrast{1};

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  % TODO maybe better to base this group field on the actual content of the
  % design matrix of this node
  groupField = regexp(fieldnames(BIDS.raw.participants.content), 'group|Group', 'match');
  groupField = groupField{~cellfun('isempty', groupField)};
  assert(numel(groupField) == 1);
  if iscell(groupField)
    groupField = groupField{1};
  end
  availableGroups = unique(BIDS.raw.participants.content.(groupField));

  if any(~ismember({group1, group2}, availableGroups))
    error(['Some requested group is not present: %s.', ...
           '\nAvailable groups in participants.tsv:\n%s'], ...
          strjoin({group1, group2}, ', '), ...
          createUnorderedList(availableGroups));
  end

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

    file = findSubjectConImage(opt, subLabel, contrastName);
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

  factorialDesign = defaultImplicitMasking(factorialDesign);

  factorialDesign = defaultGlobalCalcAndNorm(factorialDesign);

  matlabbatch{end + 1}.spm.stats.factorial_design = factorialDesign;

end

function file = findSubjectConImage(opt, subLabel, contrastName)

  file = '';

  % FFX directory and load SPM.mat of that subject
  ffxDir = getFFXdir(subLabel, opt);
  load(fullfile(ffxDir, 'SPM.mat'));

  % find which contrast of that subject has the name of the contrast we
  % want to bring to the group level
  conIdx = find(strcmp({SPM.xCon.name}, contrastName));

  if isempty(conIdx)

    msg = sprintf('Skipping subject %s. Could not find a contrast named %s\nin %s.\n', ...
                  subLabel, ...
                  contrastName, ...
                  fullfile(ffxDir, 'SPM.mat'));

    errorHandling(mfilename(), 'missingContrast', msg, true, opt.verbosity);

    printToScreen(['available contrasts:\n' createUnorderedList({SPM.xCon.name}')], ...
                  opt, 'format', 'red');

  else

    % Check which level of CON smoothing is desired
    smoothPrefix = '';
    if opt.fwhm.contrast > 0
      smoothPrefix = [spm_get_defaults('smooth.prefix'), num2str(opt.fwhm.contrast)];
    end

    fileName = sprintf('con_%0.4d.nii', conIdx);
    file = validationInputFile(ffxDir, fileName, smoothPrefix);

  end

end

function factorialDesign = defaultGlobalCalcAndNorm(factorialDesign)
  factorialDesign.globalc.g_omit = 1;
  factorialDesign.globalm.gmsca.gmsca_no = 1;
  factorialDesign.globalm.glonorm = 1;
end

function factorialDesign = defaultImplicitMasking(factorialDesign)
  factorialDesign.masking.tm.tm_none = 1;
  factorialDesign.masking.im = 1;
end
