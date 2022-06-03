function matlabbatch = bidsResults(opt)
  %
  % Computes the results for a series of contrast that can be
  % specified at the run, subject or dataset step level (see contrast specification
  % following the BIDS stats model specification).
  %
  % USAGE::
  %
  %  bidsResults(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  %
  % See also: setBatchSubjectLevelResults, setBatchGroupLevelResults
  %
  %
  % Below is an example of how specify the option structure
  % to getsome speific results outputs for certain contrasts.
  %
  % See the `online documentation <https://cpp-spm.readthedocs.io/en/dev>`_
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
  % Specify the name of the contrast whose resul we want to see.
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
  %    - ``'FWE'`` is the defaut
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
  % You can also create a montage to view the results
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
  % Finally you can export as a NIDM results zip files.
  %
  % NIDM results is a standardized results format that is readable
  % by the main neuroimaging softwares (SPM, FSL, AFNI).
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
  % (C) Copyright 2020 CPP_SPM developers

  % TODO move ps file
  % TODO rename NIDM file

  currentDirectory = pwd;

  opt.pipeline.type = 'stats';

  opt.dir.output = opt.dir.stats;

  [~, opt] = setUpWorkflow(opt, 'computing GLM results');

  BIDS = [];

  % loop trough the steps and more results to compute for each contrast
  % mentioned for each step
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

    % Depending on the level step we migh have to define a matlabbatch
    % for each subject or just on for the whole group
    switch lower(node.Level)

      case {'run', 'subject'}

        for iSub = 1:numel(opt.subjects)

          subLabel = opt.subjects{iSub};

          [opt, BIDS] = checkMontage(opt, iRes, node, BIDS, subLabel);

          printProcessingSubject(iSub, subLabel, opt);

          if strcmpi(node.Level, 'run')
            isRunLevel = true;
            batchName = sprintf('compute_sub-%s_run_level_results', subLabel);

          elseif  strcmpi(node.Level, 'subject')
            isRunLevel = false;
            batchName = sprintf('compute_sub-%s_subject_level_results', subLabel);
          end

          [matlabbatch, results] = bidsResultsSubject(opt, subLabel, iRes, isRunLevel);

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

        status = saveAndRunWorkflow(matlabbatch, batchName, opt);

        if status
          renameOutputResults(results);
        end

      otherwise

        error('This BIDS model does not contain an analysis step I understand.');

    end

  end

  cd(currentDirectory);

end

function [matlabbatch, result] = bidsResultsSubject(opt, subLabel, iRes, isRunLevel)

  matlabbatch = {};

  result.space = opt.space;

  % allow constrast.name to be a cell and loop over it
  for i = 1:length(opt.results(iRes).name)

    contrastName = opt.results(iRes).name{i};

    if isRunLevel

      % find all the contrasts: potentially up to one per run
      %
      % Only neccessary
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

    load(fullfile(getFFXdir(subLabel, opt), 'SPM.mat'), 'SPM');

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
    result.dir = getRFXdir(opt, result.nodeName, name);

    switch  groupLevelGlmType(opt, node.Name)

      case 'one_sample_t_test'
        result.name = name;

      case 'two_sample_t_test'
        thisContrast = opt.model.bm.get_contrasts('Name', node.Name);
        result.name = [thisContrast.Name ' - ' name];

      otherwise
        msg = sprintf('Node %s has has model type I cannot handle.\n', nodeName);
        notImplemented(mfilename(), msg, true);

    end

    result.space = opt.space;

    matlabbatch = setBatchGroupLevelResults(matlabbatch, ...
                                            opt, ...
                                            result);

    matlabbatch = setBatchPrintFigure(matlabbatch, ...
                                      opt, ...
                                      fullfile(result.dir, figureName(opt)));

    results{i} = result;

  end

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
  % we create new name for the nifti output by removing the
  % spmT_XXXX prefix and using the XXXX as label- for the file

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

  end

end

function renameNidm(opt, result, subLabel)
  %
  % removes the _XXX suffix before the PNG extension.

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
