function cliDefaultModel(varargin)
  % Create a default bids stats model for a raw dataset.
  %
  % Type ``bidspm help`` for more info.
  %

  % (C) Copyright 2023 bidspm developers
  args = inputParserForCreateModel();
  try
    parse(args, varargin{:});
  catch ME
    displayArguments(varargin{:});
    rethrow(ME);
  end

  opt = getOptionsFromCliArgument(args);
  if ~isfield(opt, 'taskName')
    opt.taskName = '';
  end
  opt = checkOptions(opt);

  saveOptions(opt);

  createDefaultStatsModel(opt.dir.raw, opt, lower(args.Results.ignore));
end
