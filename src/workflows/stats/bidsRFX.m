function matlabbatch = bidsRFX(varargin)
  %
  %
  % - creates a mean structural image and mean mask over the sample
  %
  % OR
  %
  % - specifies and estimates the group level model,
  % - computes the group level contrasts.
  %
  % USAGE::
  %
  %  bidsRFX(action, opt, 'nodeName', '')
  %
  % :param action: Action to be conducted: ``'RFX'`` or
  %                ``'meanAnatAndMask'`` or ``'contrast'``
  % :type action: char
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  % :type opt: structure
  %
  % :param nodeName: name of the BIDS stats model to run analysis on
  % :type nodeName: char
  %
  %

  % (C) Copyright 2020 bidspm developers

  allowedActions = @(x) ismember(lower(x), ...
                                 {'meananatandmask', 'rfx', 'contrasts'});

  args = inputParser;

  args.addRequired('action', allowedActions);
  args.addRequired('opt', @isstruct);
  args.addParameter('nodeName', '', @ischar);

  args.parse(varargin{:});

  action =  args.Results.action;
  opt =  args.Results.opt;
  nodeName =  args.Results.nodeName;

  opt.pipeline.type = 'stats';

  description = 'group level GLM';

  opt.dir.output = opt.dir.stats;

  % To speed up group level we skip indexing data
  indexData = false;
  [~, opt] = setUpWorkflow(opt, description, '', indexData);

  checks(opt);

  matlabbatch = {};

  % TODO refactor
  % - extract function for anat and mask computation

  if ismember(lower(action), {'meananatandmask', 'rfx', 'contrasts'})
    opt.dir.output = fullfile(opt.dir.stats, 'derivatives', 'bidspm-groupStats');
    opt.dir.jobs = fullfile(opt.dir.output, 'jobs',  strjoin(opt.taskName, ''));
  end

  if ismember(lower(action), {'rfx', 'contrasts'})
    % TODO add possibility to pass several nodeNames at once
    if ~isempty(nodeName)
      datasetNodes = opt.model.bm.get_nodes('Name', nodeName);
    else
      datasetNodes = opt.model.bm.get_nodes('Level', 'Dataset');
    end
    if isstruct(datasetNodes)
      datasetNodes = {datasetNodes};
    end
  end

  switch lower(action)

    case 'meananatandmask'
      % TODO need to rethink where to save the anat and mask
      matlabbatch = setBatchMeanAnatAndMask(matlabbatch, ...
                                            opt, ...
                                            opt.dir.output);
      saveAndRunWorkflow(matlabbatch, 'create_mean_struc_mask', opt);

    case 'rfx'

      participants = bids.util.tsvread(fullfile(opt.dir.raw, 'participants.tsv'));

      for i = 1:numel(datasetNodes)

        msg = sprintf('\n PROCESSING NODE: %s\n', nodeName);
        logger('INFO', msg, 'options', opt, 'filename', mfilename());

        matlabbatch = {};

        nodeName = datasetNodes{i}.Name;

        switch  groupLevelGlmType(opt, nodeName, participants)

          case {'one_sample_t_test', 'one_way_anova'}
            [matlabbatch, contrastsList, groups] = setBatchFactorialDesign(matlabbatch, ...
                                                                           opt, ...
                                                                           datasetNodes{i}.Name);
          case 'two_sample_t_test'
            [matlabbatch, contrastsList, groups] = setBatchTwoSampleTTest(matlabbatch, ...
                                                                          opt, ...
                                                                          datasetNodes{i}.Name);
          otherwise
            msg = sprintf('Node %s has has model type I cannot handle.\n', nodeName);
            notImplemented(mfilename(), msg);

        end

        matlabbatch = setBatchEstimateModel(matlabbatch, ...
                                            opt, ...
                                            datasetNodes{i}.Name, ...
                                            contrastsList, ...
                                            groups);

        checkDirIsEmpty(matlabbatch);

        status = saveAndRunWorkflow(matlabbatch, ...
                                    'group_level_model_specification_estimation', ...
                                    opt);

        renameDesignMatrixFigure(status, matlabbatch);

      end

    case 'contrasts'

      opt.model.bm.validateConstrasts();

      for i = 1:numel(datasetNodes)
        matlabbatch = setBatchGroupLevelContrasts(matlabbatch, opt, datasetNodes{i}.Name);
        saveAndRunWorkflow(matlabbatch, 'contrasts_rfx', opt);
      end

  end

  if ismember(lower(action), {'meananatandmask', 'rfx'})
    opt.pipeline.name = 'bidspm';
    opt.pipeline.type = 'groupStats';
    initBids(opt, 'description', description, 'force', false);
  end

  cleanUpWorkflow(opt);

end

function checks(opt)
  if numel(opt.space) > 1
    disp(opt.space);
    msg = sprintf('GLMs can only be run in one space at a time.\n');
    id = 'tooManySpaces';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end
end

function checkDirIsEmpty(matlabbatch)

  % make sure there is no SPM.mat in the target dir
  %
  % folders where the model is to be specified have already been emptied
  % if at this stage they are not, something has gone horribly wrong.
  %
  % also if we continued SPM would ask us to manually confirm the over-write
  % by clicking buttons and no one has got time this
  for i = 1:numel(matlabbatch)

    if isfield(matlabbatch{i}.spm, 'stats') && ...
        isfield(matlabbatch{i}.spm.stats, 'fmri_est')
      if exist(matlabbatch{i}.spm.stats.fmri_est.spmmat{1}, 'file')
        logger('ERROR', 'About to overwrite a model. That should not happen', ...
               'filename', mfilename(), ...
               'id', 'overWriteModel');
      end
    end

  end

end

function renameDesignMatrixFigure(status, matlabbatch)

  if ~status
    return
  end

  for j = 1:numel(matlabbatch)
    if isfield(matlabbatch{j}.spm, 'stats') && ...
        isfield(matlabbatch{j}.spm.stats, 'fmri_est')
      directory = fileparts(matlabbatch{j}.spm.stats.fmri_est.spmmat{1});
      renamePng(directory, 'task');
    end
  end

end
