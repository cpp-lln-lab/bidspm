function cliCreateRoi(varargin)
  % (C) Copyright 2022 bidspm developers
  args = inputParserForCreateRoi();
  parse(args, varargin{:});

  opt = getOptionsFromCliArgument(args);
  opt = checkOptions(opt);
  opt.roi.space = opt.space;
  saveOptions(opt);

  boilerplate(opt, ...
              'outputPath', fullfile(opt.dir.roi, 'reports'), ...
              'pipelineType', 'create_roi', ...
              'verbosity', 0);

  if opt.boilerplate_only
    return
  end

  bidsCreateROI(opt);
end
