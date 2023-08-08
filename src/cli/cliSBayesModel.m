function cliSBayesModel(varargin)
  % Run stats on bids datasets.
  %
  % Type ``bidspm help`` for more info.
  %

  % TODO make sure that options defined in JSON or passed as a structure
  % overrides any other arguments

  % (C) Copyright 2023 bidspm developers
  args = inputParserForBayesModel();
  parse(args, varargin{:});

  validate(args);

  opt = getOptionsFromCliArgument(args);

  opt.pipeline.type = 'stats';
  opt = checkOptions(opt);

  action = args.Results.action;

  saveOptions(opt);

  bidsModelSelection(opt, 'action', action);

end