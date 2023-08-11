function opt = getOptionsFromCliArgument(args)
  %
  % USAGE::
  %
  %   opt = getOptionsFromCliArgument(args)
  %
  %

  % (C) Copyright 2022 bidspm developers

  action = args.Results.action;

  if ~ismember(lower(action), bidsAppsActions)
    return
  end

  bidspm('action', 'init');

  opt = getOptions(args);

  opt.verbosity = args.Results.verbosity;

  opt.dir.raw = args.Results.bids_dir;
  opt.dir.derivatives = args.Results.output_dir;

  if ~isempty(args.Results.participant_label)
    opt.subjects = args.Results.participant_label;
  end

  if ~isempty(args.Results.bids_filter_file)
    % TODO read from JSON if necessary
    % TODO validate
    opt.bidsFilterFile = args.Results.bids_filter_file;
  end

  opt = overrideSpace(opt, args);

  if isfield(args.Results, 'task')
    opt.taskName = args.Results.task;
  end

  if isfield(args.Results, 'boilerplate_only')
    opt.boilerplateOnly = args.Results.boilerplate_only;
  end

  if isfield(args.Results, 'dry_run')
    opt = overrideDryRun(opt, args);
  end

  if isfield(args.Results, 'fwhm')
    opt = overrideFwhm(opt, args);
  end

  if isfield(args.Results, 'anat_only') && args.Results.anat_only == true
    opt.anatOnly = true;
    opt.query.modality = {'anat'};
  end

  opt = optionsPreprocessing(opt, args, action);

  if ismember(lower(action), {'create_roi', ...
                              'stats', ...
                              'contrasts', ...
                              'results', ...
                              'specify_only'})
    opt.dir.preproc = args.Results.preproc_dir;
  end

  opt = roiOptions(opt, args);

  opt = optionsStats(opt, args, action);

  if ismember(lower(action), {'bms'})
    opt.toolbox.MACS.model.dir = args.Results.models_dir;
  end

end

function opt = optionsPreprocessing(opt, args, action)
  if ismember(lower(action), {'preprocess'})

    if ismember('slicetiming', args.Results.ignore)
      opt.stc.skip = true;
    end
    if ismember('unwarp', args.Results.ignore)
      opt.realign.useUnwarp = false;
    end
    if ismember('fieldmaps', args.Results.ignore)
      opt.useFieldmaps = false;
    end
    if ismember('qa', lower(args.Results.ignore))
      opt.QA.func.do = false;
      opt.QA.anat.do = false;
      opt.QA.glm.do = false;
    end

    opt.dummyScans = args.Results.dummy_scans;

    opt.anatOnly = args.Results.anat_only;

  end
end

function opt = optionsStats(opt, args, action)
  if ismember(lower(action), {'stats', ...
                              'contrasts', ...
                              'results', ...
                              'specify_only'})
    opt.dir.preproc = args.Results.preproc_dir;

    % can only be a struct, file or dir
    opt.model.file = args.Results.model_file;
    if ~isstruct(opt.model.file)
      if isdir(opt.model.file)
        opt.model.file = spm_select('FPList', ...
                                    opt.model.file, ...
                                    '.*_smdl.json');
      end
    end

    opt.model.designOnly = args.Results.design_only;

    opt.glm.keepResiduals = args.Results.keep_residuals;

    opt.glm.useDummyRegressor =  args.Results.use_dummy_regressor;

    opt = overrideRoiBased(opt, args);

  end
end

function value = bidsAppsActions()

  value = {'copy'; ...
           'create_roi'; ...
           'preprocess'; ...
           'smooth'; ...
           'default_model'; ...
           'stats'; ...
           'contrasts'; ...
           'results'; ...
           'specify_only'; ...
           'bms'};
end

function opt = getOptions(args)
  if isstruct(args.Results.options)
    opt = args.Results.options;
  elseif exist(args.Results.options, 'file') == 2
    opt = bids.util.jsondecode(args.Results.options);
  end
  if isempty(opt)
    % set defaults
    opt = checkOptions(struct());
  end
end

function opt = roiOptions(opt, args)
  if isfield(args.Results, 'roi_dir')
    opt.dir.roi = args.Results.roi_dir;
  end
  if isfield(args.Results, 'roi_atlas')
    opt.roi.atlas = args.Results.roi_atlas;
  end
  if isfield(args.Results, 'roi_name')
    opt.roi.name = args.Results.roi_name;
  end
  if isfield(args.Results, 'hemisphere')
    opt.roi.hemi = args.Results.hemisphere;
  end
end

function opt = overrideRoiBased(opt, args)
  if isfield(opt, 'glm') && isfield(opt.glm, 'roibased') && ...
      isfield(opt.glm.roibased, 'do') && opt.glm.roibased.do ~= args.Results.roi_based
    overrideMsg('roi_based', convertToString(args.Results.roi_based), ...
                'glm.roibased.do', convertToString(opt.glm.roibased.do), ...
                opt);
  end
  opt.glm.roibased.do = args.Results.roi_based;
end

function opt = overrideDryRun(opt, args)
  if isfield(opt, 'dryRun') && args.Results.dry_run ~= opt.dryRun
    overrideMsg('dry_run', convertToString(args.Results.dry_run), ...
                'dryRun', convertToString(opt.dryRun), ...
                opt);
  end
  opt.dryRun = args.Results.dry_run;
end

function opt = overrideFwhm(opt, args)
  if ~isempty(args.Results.fwhm) && ...
     (isfield(opt, 'fwhm') && isfield(opt.fwhm, 'func')) && ...
     args.Results.fwhm ~= opt.fwhm.func
    overrideMsg('fwhm', convertToString(args.Results.fwhm), ...
                'fwhm.func', convertToString(opt.fwhm.func), ...
                opt);
  end
  opt.fwhm.func = args.Results.fwhm;
end

function opt = overrideSpace(opt, args)
  if ~isfield(args.Results, 'space')
    return
  end
  if ~isempty(args.Results.space)
    if isfield(opt, 'space') && ~all(ismember(args.Results.space, opt.space))
      overrideMsg('space', convertToString(args.Results.space), ...
                  'space', convertToString(opt.space), ...
                  opt);
    end
    opt.space = args.Results.space;
  end
end

function output = convertToString(input)
  if islogical(input) && input == true
    output = 'true';
  elseif islogical(input) && input == false
    output = 'false';
  elseif isnumeric(input)
    output = num2str(input);
  elseif iscellstr(input)
    output = strjoin(input, ', ');
  end
end

function overrideMsg(thisArgument, newValue, thisOption, oldValue, opt)

  msg = sprintf('\nArgument "%s" value "%s" will override option "%s" value "%s".', ...
                thisArgument, ...
                newValue, ...
                thisOption, ...
                oldValue);
  logger('DEBUG', msg, 'options', opt, 'filename', mfilename());

end
