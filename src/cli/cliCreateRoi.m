function cliCreateRoi(varargin)
  % Create a ROI from an atlas.
  %
  % Type ``bidspm help`` for more info.
  %

  % (C) Copyright 2023 bidspm developers
  args = inputParserForCreateRoi();
  try
    parse(args, varargin{:});
  catch ME
    displayArguments(varargin{:});
    rethrow(ME);
  end

  opt = getOptionsFromCliArgument(args);
  opt = checkOptions(opt);
  opt.roi.space = opt.space;

  saveOptions(opt);

  boilerplate(opt, ...
              'outputPath', fullfile(opt.dir.roi, 'reports'), ...
              'pipelineType', 'create_roi', ...
              'verbosity', 0);

  if opt.boilerplateOnly
    return
  end

  bidsCreateROI(opt);
end
