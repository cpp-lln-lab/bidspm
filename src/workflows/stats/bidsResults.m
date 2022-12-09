function matlabbatch = bidsResults(varargin)
  %
  % Computes the results for a series of contrast that can be
  % specified at the run, subject or dataset step level
  % (see contrast specification following the BIDS stats model specification).
  %
  % USAGE::
  %
  %   bidsResults(opt,'nodeName', '')
  %
  % :param opt: Options chosen for the analysis.
  %             See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % :param nodeName: name of the BIDS stats model Node(s) to show results of
  % :type nodeName: char or cellstr
  %
  % See also: setBatchSubjectLevelResults, setBatchGroupLevelResults
  %
  %
  % Below is an example of how specify the option structure
  % to get some specific results outputs for certain contrasts.
  %
  % See the `online documentation <https://bidspm.readthedocs.io/en/dev>`_
  % for example of those outputs.
  %
  % The field ``opt.results`` allows you to get results from several Nodes
  % from the BIDS stats model. So you could run ``bidsResults`` once to view
  % results from the subject and the dataset level.
  %
  % Specify a default structure result for this node::
  %
  %   opt.results(1) = returnDefaultResultsStructure();
  %
  % Specify the Node name (usually "run_level", "subject_levle" or "dataset_level")::
  %
  %   opt.results(1).nodeName = 'subject_level';
  %
  % Specify the name of the contrast whose result we want to see.
  % This must match one of the existing contrats (dummy contrast or contrast)
  % in the BIDS stats model for that Node::
  %
  %   opt.results(1).name = 'listening_1';
  %
  % For each contrat, you can adapt:
  %
  %  - voxel level threshold (``p``) [between 0 and 1]
  %  - cluster level threshold (``k``) [positive integer]
  %  - type of multiple comparison (``MC``):
  %
  %    - ``'FWE'`` is the default
  %    - ``'FDR'``
  %    - ``'none'``
  %
  % You can thus specify something different for a second contrast::
  %
  %   opt.results(2).name = {'listening_lt_baseline'};
  %   opt.results(2).MC =  'none';
  %   opt.results(2).p = 0.01;
  %   opt.results(2).k = 0;
  %
  % Specify how you want your output
  % (all the following are on ``false`` by default):
  %
  % .. code-block:: matlab
  %
  %   % simple figure with glass brain view and result table
  %   opt.results(1).png = true();
  %
  %   % result table as a .csv: very convenient when comes the time to write papers
  %   opt.results(1).csv = true();
  %
  %   % thresholded statistical map
  %   opt.results(1).threshSpm = true();
  %
  %   % binarised thresholded statistical map (useful to create ROIs)
  %   opt.results(1).binary = true();
  %
  % You can also create a montage to view the results with
  % `opt.results(1).csv = true();` activation neuroanatomical location
  % will be labelled.
  % You can specify the atlas to use for that by choosing between
  %
  %  - `'Neuromorphometrics'` (default)
  %  - `'aal'`
  %
  % .. code-block:: matlab
  %
  %   opt.results(1).atlas = 'Neuromorphometrics';
  %
  % on several slices at once:
  %
  % .. code-block:: matlab
  %
  %   opt.results(1).montage.do = true();
  %
  %   % slices position in mm [a scalar or a vector]
  %   opt.results(1).montage.slices = -0:2:16;
  %
  %   % slices orientation: can be 'axial' 'sagittal' or 'coronal'
  %   % axial is default
  %   opt.results(1).montage.orientation = 'axial';
  %
  %   % path to the image to use as underlay
  %   % Will use the SPM MNI T1 template by default
  %   opt.results(1).montage.background = ...
  %        fullfile(spm('dir'), 'canonical', 'avg152T1.nii');
  %
  %   % Can also be a structure to pick up the correct file for each subject
  %   % opt.results(1).montage.background = struct('suffix', 'T1w', ...
  %   %                                            'desc', 'preproc', ...
  %   %                                            'modality', 'anat');
  %
  %
  % Finally you can export as a NIDM results zip files.
  %
  % NIDM results is a standardized results format that is readable
  % by the main neuroimaging software (SPM, FSL, AFNI).
  % Think of NIDM as BIDS for your statistical maps.
  % One of the main other advantage is that it makes it VERY easy
  % to share your group results on `neurovault <https://neurovault.org/>`_
  % (which you should systematically do).
  %
  % - `NIDM paper <https://www.hal.inserm.fr/view/index/identifiant/inserm-01570626>`_
  % - `NIDM specification <http://nidm.nidash.org/specs/nidm-results_130.html>`_
  % - `NIDM results viewer for SPM <https://github.com/incf-nidash/nidmresults-spmhtml>`
  %
  % To generate NIDM results zip file for a given contrats simply::
  %
  %   opt.results(1).nidm = true();
  %

  % (C) Copyright 2020 bidspm developers

  % TODO move ps / png file: difficult at subject level because there can be
  %                          several png for one contrast
  % TODO rename NIDM file:

  matlabbatch = {};

  args = inputParser;

  args.addRequired('opt', @isstruct);
  args.addParameter('nodeName', '');

  args.parse(varargin{:});

  opt =  args.Results.opt;

  nodeName =  args.Results.nodeName;

  %%
  currentDirectory = pwd;

  opt.pipeline.type = 'stats';

  opt.dir.output = opt.dir.stats;

  status = checks(opt);
  if ~status
    return
  end

  % filter results to keep only the one requested
  % modifies opt.results in place
  if ~isempty(nodeName)
    if ischar(nodeName)
      nodeName = {nodeName};
    end
    listNodeNames = returnListNodeNames(opt);
    keep = ismember(listNodeNames, nodeName);
    opt.results = opt.results(keep);
  end

  % skip data indexing if we are only at the group level
  indexData = true;
  listNodeLevels = returnlistNodeLevels(opt);
  if all(ismember(listNodeLevels, 'dataset'))
    indexData = false;
  end
  [~, opt] = setUpWorkflow(opt, 'computing GLM results', [], indexData);

  BIDS = [];

  % loop through the steps to compute for each contrast mentioned for each node
  for iRes = 1:length(opt.results)

    node = opt.model.bm.get_nodes('Name',  opt.results(iRes).nodeName);

    if isempty(node)
      errorHandling(mfilename(), ...
                    'unknownModelNode', ...
                    sprintf('no Node named %s in model\n %s.', ...
                            opt.results(iRes).nodeName, ...
                            opt.model.file), ...
                    true, ...
                    opt.verbosity);
      continue
    end

    msg = sprintf('\n PROCESSING NODE: %s\n', node.Name);
    logger('INFO', msg, opt, mfilename);

    % Depending on the level step we might have to define a matlabbatch
    % for each subject or just on for the whole group
    switch lower(node.Level)

      case {'run', 'subject'}

        for iSub = 1:numel(opt.subjects)

          subLabel = opt.subjects{iSub};

          printProcessingSubject(iSub, subLabel, opt);

          if strcmpi(node.Level, 'run')
            isRunLevel = true;
            batchName = sprintf('compute_sub-%s_run_level_results', subLabel);

          elseif  strcmpi(node.Level, 'subject')
            isRunLevel = false;
            batchName = sprintf('compute_sub-%s_subject_level_results', subLabel);
          end

          [optThisSubject, BIDS] = checkMontage(opt, iRes, node, BIDS, subLabel);
          [matlabbatch, results] = bidsResultsSubject(optThisSubject, subLabel, iRes, isRunLevel);

          status = saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

          if status
            renameOutputResults(results);
            renameNidm(opt, results, subLabel);
          end

        end

      case 'session'

        notImplemented(mfilename, 'session level results not implemented yet', opt.verbosity);

        continue

      case 'dataset'

        [matlabbatch, results] = bidsResultsDataset(opt, iRes);

        batchName = 'compute_group_level_results';

        tmp = fullfile(opt.dir.stats, 'derivatives', 'bidspm-groupStats');
        opt.dir.jobs = fullfile(tmp, 'jobs',  strjoin(opt.taskName, ''));
        status = saveAndRunWorkflow(matlabbatch, batchName, opt);

        if status
          renameOutputResults(results);
        end

      otherwise

        error('This BIDS model does not contain an analysis step I understand.');

    end

  end

  cd(currentDirectory);

  cleanUpWorkflow(opt);

end

function [status] = checks(opt)

  status = true;

  msg = sprintf(['Specify node names and levels in "opt.results".', ...
                 '\t\nType "help bidsResults" for more information.']);

  if ~isfield(opt, 'results') || isempty(opt.results)
    errorHandling(mfilename(), 'noResultsAsked', msg, true, true);
    status = false;
  end

  listNodeNames = returnListNodeNames(opt);
  listNodeLevels = returnlistNodeLevels(opt);

  if isempty(listNodeNames) || isempty(listNodeLevels)
    errorHandling(mfilename(), 'noResultsAsked', msg, true, true);
    status = false;
    return
  end

end

function listNodeNames = returnListNodeNames(opt)

  listNodeNames = {};

  for iRes = 1:numel(opt.results)
    if ~isempty(opt.results(iRes).nodeName)
      node = opt.model.bm.get_nodes('Name',  opt.results(iRes).nodeName);
      listNodeNames{iRes} = node.Name; %#ok<*AGROW>
    end
  end

end

function listNodeLevels = returnlistNodeLevels(opt)

  listNodeLevels = {};

  for iRes = 1:numel(opt.results)
    if ~isempty(opt.results(iRes).nodeName)
      node = opt.model.bm.get_nodes('Name',  opt.results(iRes).nodeName);
      listNodeLevels{iRes} = lower(node.Level);
    end
  end

end

function [matlabbatch, result] = bidsResultsSubject(opt, subLabel, iRes, isRunLevel)

  matlabbatch = {};

  result.space = opt.space;

  % allow contrast.name to be a cell and loop over it
  for i = 1:length(opt.results(iRes).name)

    contrastName = opt.results(iRes).name{i};

    if isRunLevel

      % find all the contrasts: potentially up to one per run
      %
      % Only necessary
      % if the user did not specify the run number in result.name
      % by adding an "_[0-9]*" to indicate the run number to get this contrast
      % for example
      %
      %  opt.result.name = 'listening_1'
      %

      endsWithRunNumber = regexp(contrastName, '_[0-9]*\${0,1}$', 'match');
      if isempty(endsWithRunNumber)
        tmp.name = [contrastName '_[0-9]*'];
      else
        tmp.name = contrastName;
      end

    else

      tmp.name = contrastName;

    end

    tmp.dir = getFFXdir(subLabel, opt);

    status = checkSpmMat(tmp.dir);

    if ~status
      return
    end

    load(fullfile(tmp.dir, 'SPM.mat'), 'SPM');

    contrastNb = getContrastNb(tmp, opt, SPM);

    constrastsNamesList = {SPM.xCon(contrastNb).name}';

    for j = 1:numel(constrastsNamesList)

      result = opt.results(iRes);

      result.name = constrastsNamesList{j};

      if ~isRunLevel
        % skip contrast with name ending in _[0-9]* as they are run level
        % contrasts
        endsWithRunNumber = regexp(result.name, '_[0-9]*$', 'match');
        if ~isempty(endsWithRunNumber)
          continue
        end
      end

      result.space = opt.space;

      result.dir = getFFXdir(subLabel, opt);

      matlabbatch = setBatchSubjectLevelResults(matlabbatch, ...
                                                opt, ...
                                                subLabel, ...
                                                result);
    end

  end

end

function [matlabbatch, results] = bidsResultsDataset(opt, iRes)

  BIDS = '';

  matlabbatch = {};

  results = {};

  node = opt.model.bm.get_nodes('Name',  opt.results(iRes).nodeName);

  opt = checkMontage(opt, iRes, node);

  for i = 1:length(opt.results(iRes).name)

    result = opt.results(iRes);

    name = opt.results(iRes).name{i};
    if isempty(name)
      unfold(opt.results(iRes));
      msg = 'No name specified for this result. May lead to failure.';
      id = 'unSpecifiedResultName';
      errorHandling(mfilename(), id, msg, true, opt.verbosity);
    end

    switch  groupLevelGlmType(opt, result.nodeName)

      case 'one_sample_t_test'

        [~, ~, groupBy] =  groupLevelGlmType(opt, result.nodeName);

        if all(ismember(lower(groupBy), {'contrast'}))

          result.name = name;
          result.contrastNb = 1;
          result.dir = getRFXdir(opt, result.nodeName, name);

          [matlabbatch, results] = appendToBatch(matlabbatch, opt, results, result);

        elseif all(ismember(lower(groupBy), {'contrast', 'group'}))

          participants = bids.util.tsvread(fullfile(opt.dir.raw, 'participants.tsv'));

          groupColumnHdr = groupBy{ismember(lower(groupBy), {'group'})};
          availableGroups = unique(participants.(groupColumnHdr));

          for iGroup = 1:numel(availableGroups)

            thisGroup = availableGroups{iGroup};
            result.name = [thisGroup ' - ' name];
            result.contrastNb = 1;
            result.dir = getRFXdir(opt, result.nodeName, name, thisGroup);

            [matlabbatch, results] = appendToBatch(matlabbatch, opt, results, result);

          end

        end

      case 'two_sample_t_test'

        thisContrast = opt.model.bm.get_contrasts('Name', result.nodeName);

        result.dir = getRFXdir(opt, result.nodeName, name);

        for  iCon = 1:numel(thisContrast)
          result.name = [thisContrast{iCon}.Name ' - ' name];
          result.contrastNb = iCon;
          [matlabbatch, results] = appendToBatch(matlabbatch, opt, results, result);
        end

      otherwise
        msg = sprintf('Node %s has has model type I cannot handle.\n', result.nodeName);
        notImplemented(mfilename(), msg, true);

    end

  end

end

function status = checkSpmMat(dir)
  status = exist(fullfile(dir, 'SPM.mat'), 'file');
  if ~status
    msg = sprintf('\nCould not find a SPM.mat file in directory %s\n', dir);
    id = 'noSpmMatFile';
    errorHandling(mfilename(), id, msg, true, true);
  end
end

function [matlabbatch, results] = appendToBatch(matlabbatch, opt, results, result)

  if ~checkSpmMat(result.dir)
    return
  end

  result.space = opt.space;

  matlabbatch = setBatchGroupLevelResults(matlabbatch, opt, result);

  %   matlabbatch = setBatchPrintFigure(matlabbatch, opt, fullfile(result.dir, figureName(opt)));

  results{end + 1} = result;

end

function [opt, BIDS] = checkMontage(opt, iRes, node, BIDS, subLabel)

  if nargin < 4
    BIDS = '';
    subLabel = '';
  end

  if isfield(opt.results(iRes), 'montage') && any(opt.results(iRes).montage.do)

    background = opt.results(iRes).montage.background;

    % TODO refactor with getInclusiveMask
    if isstruct(background)

      if ismember(lower(node.Level), {'run', 'session', 'subject'})

        if isempty(BIDS)
          BIDS =  bids.layout(opt.dir.preproc, 'use_schema', false);
        end

        background.sub = subLabel;
        background.space = opt.space;
        file = bids.query(BIDS, 'data', background);

        if iscell(file)
          if isempty(file)
            % let checkMaskOrUnderlay figure it out
            file = '';

          elseif numel(file) == 1
            file = file{1};

          elseif numel(file) > 1
            file = file{1};

            msg = sprintf('More than 1 overlay image found for %s.\n Taking the first one.', ...
                          createUnorderedList(background));
            id = 'tooManyMontageBackground';
            errorHandling(mfilename(), id, msg, true, opt.verbosity);
          end

        end

        background = file;

      end

    end

    background = checkMaskOrUnderlay(background, opt, 'background');
    opt.results(iRes).montage.background = background;

  end

end

function renameOutputResults(results)
  %
  % we create new name for the nifti output by removing the
  % spmT_XXXX prefix and using the XXXX as label- for the file
  %
  % also rename PNG and labels activations
  %

  for i = 1:numel(results)

    if iscell(results)
      result = results{i};
    elseif isstruct(results)
      result = results(i);
    end

    outputFiles = spm_select('FPList', result.dir, '^spmT_[0-9].*_sub-.*$');

    for iFile = 1:size(outputFiles, 1)

      source = deblank(outputFiles(iFile, :));

      basename = spm_file(source, 'basename');
      split = strfind(basename, '_sub');
      bf = bids.File(basename(split + 1:end));
      bf.entities.label = basename(split - 4:split - 1);

      target = spm_file(source, 'basename', bf.filename);

      movefile(source, target);
    end

    renamePng(result.dir);

    if result.csv && isMni(result.space)

      csvFiles = spm_select('FPList', result.dir, '^spm_.*[0-9].csv$');

      for iFile = 1:size(csvFiles, 1)
        source = deblank(csvFiles(iFile, :));
        labelActivations(source, 'atlas', result.atlas);
      end

    end

  end

end

function renameNidm(opt, result, subLabel)
  %
  % removes the _XXX suffix before the nidm extension.

  nidmFiles = spm_select('FPList', result.dir, '^spm_[0-9]{4}.nidm.zip$');

  for iFile = 1:size(nidmFiles, 1)
    source = deblank(nidmFiles(iFile, :));
    basename =  spm_file(source, 'basename');
    label =  regexp(basename, '[0-9]{4}', 'match');
    spec = struct('suffix', 'nidm', ...
                  'ext', '.zip', ...
                  'entities', struct('sub', subLabel, ...
                                     'task', strjoin(opt.taskName, ''), ...
                                     'space', opt.space, ...
                                     'label', label{1}));
    bf = bids.File(spec, 'use_schema', false);
    bf = bf.reorder_entities();
    bf = bf.update;
    target = fullfile(result.dir, bf.filename);
    movefile(source, target);
  end

end

function filename = figureName(opt)
  spec = struct('suffix', 'designmatrix', ...
                'ext', '.png', ...
                'entities', struct( ...
                                   'task', strjoin(opt.taskName, ''), ...
                                   'space', opt.space));
  bf = bids.File(spec, 'use_schema', false);
  filename = bf.filename;
end
