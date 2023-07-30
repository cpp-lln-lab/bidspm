function cliSmooth(varargin)
  % (C) Copyright 2022 bidspm developers

  % TODO make sure that options defined in JSON or passed as a structure
  % overrides any other arguments
  args = inputParserForSmooth();
  parse(args, varargin{:});

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
