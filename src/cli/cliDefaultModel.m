function cliDefaultModel(varargin)
  % (C) Copyright 2022 bidspm developers
  args = inputParserForCreateModel();
  parse(args, varargin{:});
  opt = getOptionsFromCliArgument(args);
  if ~isfield(opt, 'taskName')
    opt.taskName = '';
  end
  opt = checkOptions(opt);

  saveOptions(opt);
  createDefaultStatsModel(opt.dir.raw, opt, lower(args.Results.ignore));
end
