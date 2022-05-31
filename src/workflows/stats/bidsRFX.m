function matlabbatch = bidsRFX(varargin)
  %
  % - smooths all contrast images created at the subject level
  %
  % OR
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
  %  bidsRFX(action, opt)
  %
  % :param action: Action to be conducted: ``'smoothContrasts'`` or ``'RFX'`` or
  %                ``'meanAnatAndMask'`` or ``'contrast'``
  % :type action: string
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % :param nodeName: name of the BIDS stats model to run analysis on
  % :type nodeName: char
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  allowedActions = @(x) ismember(lower(x), ...
                                 {'smoothcontrasts', 'meananatandmask', 'rfx', 'contrast'});

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
  [~, opt] = setUpWorkflow(opt, description, [], indexData);

  checks(opt);

  matlabbatch = {};

  % TODO refactor
  % - extract function for contrast smoothing
  % - extract function for anat and mask computation
  % - merge rfx and ffx into a single "stats" workflow

  if ismember(lower(action), {'meananatandmask', 'rfx', 'contrast'})
    opt.dir.output = fullfile(opt.dir.stats, 'derivatives', 'cpp_spm-groupStats');
    opt.dir.jobs = fullfile(opt.dir.output, 'jobs',  strjoin(opt.taskName, ''));
  end

  if ismember(lower(action), {'rfx', 'contrast'})
    if ~isempty(nodeName)
      datasetNodes = opt.model.bm.get_nodes('Name', nodeName);
    else
      datasetNodes = opt.model.bm.get_nodes('Level', 'Dataset');
    end
  end

  switch lower(action)

    case 'smoothcontrasts'
      % TODO split this in a different workflow
      matlabbatch = setBatchSmoothConImages(matlabbatch, opt);
      saveAndRunWorkflow(matlabbatch, ...
                         ['smooth_con_FWHM-', num2str(opt.fwhm.contrast), ...
                          '_task-', strjoin(opt.taskName, '')], ...
                         opt);

    case 'meananatandmask'
      % TODO need to rethink where to save the anat and mask
      matlabbatch = setBatchMeanAnatAndMask(matlabbatch, ...
                                            opt, ...
                                            opt.dir.output);
      saveAndRunWorkflow(matlabbatch, 'create_mean_struc_mask', opt);

    case 'rfx'

      for i = 1:numel(datasetNodes)

        nodeName = datasetNodes{i}.Name;

        switch  groupLevelGlmType(opt, nodeName)

          case 'one_sample_t_test'
            [matlabbatch, contrastsList] = setBatchFactorialDesign(matlabbatch, ...
                                                                   opt, ...
                                                                   datasetNodes{i}.Name);
          case 'two_sample_t_test'
            [matlabbatch, contrastsList] = setBatchTwoSampleTTest(matlabbatch, ...
                                                                  opt, ...
                                                                  datasetNodes{i}.Name);
          otherwise
            msg = sprintf('Node %s has has model type I cannot handle.\n', nodeName);
            notImplemented(mfilename(), msg, true);

        end

        matlabbatch = setBatchEstimateModel(matlabbatch, opt, datasetNodes{i}.Name, contrastsList);
        saveAndRunWorkflow(matlabbatch, 'group_level_model_specification_estimation', opt);

      end

    case 'contrast'

      for i = 1:numel(datasetNodes)
        matlabbatch = setBatchGroupLevelContrasts(matlabbatch, opt, datasetNodes{i}.Name);
        saveAndRunWorkflow(matlabbatch, 'contrasts_rfx', opt);
      end

  end

  if ismember(lower(action), {'meananatandmask', 'rfx'})
    opt.pipeline.name = 'cpp_spm';
    opt.pipeline.type = 'groupStats';
    initBids(opt, 'description', description, 'force', false);
  end
end

function checks(opt)
  if numel(opt.space) > 1
    disp(opt.space);
    msg = sprintf('GLMs can only be run in one space at a time.\n');
    errorHandling(mfilename(), 'tooManySpaces', msg, false, opt.verbosity);
  end
end
