function cliSmooth(varargin)
  % Smooth an fmriprep dataset.
  %
  % Type ``bidspm help`` for more info.
  %

  % (C) Copyright 2023 bidspm developers

  % TODO make sure that options defined in JSON or passed as a structure
  % overrides any other arguments
  args = inputParserForSmooth();
  try
    parse(args, varargin{:});
  catch ME
    displayArguments(varargin{:});
    rethrow(ME);
  end

  opt = getOptionsFromCliArgument(args);
  opt.pipeline.type = 'preproc';
  opt = checkOptions(opt);
  saveOptions(opt);

  cliCopy(varargin{:});

  if opt.fwhm.func > 0
    opt.query.desc = 'preproc';
    bidsSmoothing(opt);
  end

end
