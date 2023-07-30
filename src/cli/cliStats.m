function cliStats(varargin)

  % TODO make sure that options defined in JSON or passed as a structure
  % overrides any other arguments

  % (C) Copyright 2023 bidspm developers
  args = inputParserForStats();
  parse(args, varargin{:});

  validate(args);

  opt = getOptionsFromCliArgument(args);
  if opt.glm.roibased.do
    opt.bidsFilterFile.roi.space = opt.space;
    opt.bidsFilterFile.roi.label = opt.roi.name;
  end
  opt.pipeline.type = 'stats';
  opt = checkOptions(opt);

  action = args.Results.action;
  analysisLevel = args.Results.analysis_level;
  nodeName = args.Results.node_name;
  concatenate = args.Results.concatenate;

  isSubjectLevel = strcmp(analysisLevel, 'subject');
  estimate = strcmp(action, 'stats');
  contrasts = ismember(action, {'stats', 'contrasts'});
  results = ismember(action, {'stats', 'contrasts', 'results'});

  if opt.model.designOnly
    contrasts = false;
    results = false;
  end

  saveOptions(opt);

  boilerplate(opt, ...
              'outputPath', fullfile(opt.dir.output, 'reports'), ...
              'pipelineType', 'stats', ...
              'verbosity', 0);
  if opt.boilerplate_only
    return
  end

  if opt.glm.roibased.do

    bidsFFX('specify', opt);
    if ~opt.model.designOnly
      bidsRoiBasedGLM(opt);
    end

  else

    if estimate

      if isSubjectLevel
        if opt.model.designOnly
          bidsFFX('specify', opt);
        else
          bidsFFX('specifyAndEstimate', opt);
        end

      else
        if opt.fwhm.contrast > 0
          bidsSmoothContrasts(opt);
        end
        bidsRFX('RFX', opt, 'nodeName', nodeName);

      end

    end

    if contrasts
      if isSubjectLevel
        bidsFFX('contrasts', opt);
      else
        bidsRFX('contrasts', opt, 'nodeName', nodeName);
      end

      if isSubjectLevel && concatenate
        bidsConcatBetaTmaps(opt);
      end

    end

    if results
      bidsResults(opt, 'nodeName', nodeName);
    end

  end

end
