function cliPreprocess(varargin)
  % Preprocess a bids dataset.
  %
  % Type ``bidspm help`` for more info.
  %

  % TODO make sure that options defined in JSON or passed as a structure
  % overrides any other arguments

  % (C) Copyright 2023 bidspm developers
  args = inputParserForPreprocess();
  parse(args, varargin{:});

  if ~strcmp(args.Results.analysis_level, 'subject')
    errorHandling(mfilename(), ...
                  'noGroupLevelPreproc', ...
                  '"analysis_level" must be "subject" for preprocessing', ...
                  false);
  end

  validate(args);

  opt = getOptionsFromCliArgument(args);
  opt.pipeline.type = 'preproc';
  opt = checkOptions(opt);
  saveOptions(opt);

  if ~opt.anatOnly && (isempty(opt.taskName) || numel(opt.taskName) > 1)
    errorHandling(mfilename(), ...
                  'onlyOneTaskForPreproc', ...
                  'A single task must be specified for preprocessing', ...
                  false);
  end

  bidsReport(opt);
  boilerplate(opt, ...
              'outputPath', fullfile(opt.dir.output, 'reports'), ...
              'pipelineType', 'preprocess', ...
              'verbosity', 0);
  if opt.boilerplate_only
    return
  end

  bidsCopyInputFolder(opt);

  if opt.dummy_scans > 0
    tmpOpt = opt;
    tmpOpt.dir.input = tmpOpt.dir.preproc;
    bidsRemoveDummies(tmpOpt, ...
                      'dummyScans', tmpOpt.dummy_scans, ...
                      'force', false);
  end

  bidsCheckVoxelSize(opt);

  if opt.useFieldmaps && ~opt.anatOnly
    bidsCreateVDM(opt);
  end

  if ~opt.stc.skip && ~opt.anatOnly
    bidsSTC(opt);
  end

  bidsSpatialPrepro(opt);

  if opt.fwhm.func > 0
    opt.query.desc = 'preproc';
    if opt.dryRun
      msg = ['"dryRun" set to "true", so smoothing will be skipped', ...
             ' as it requires the output of spatial preprocessing to run.'];
      logger('WARNING', msg, ...
             'options', opt, ...
             'filename', mfilename(), ...
             'id', 'skipSmoothingInDryRun');
      return
    end
    bidsSmoothing(opt);
  end

end
