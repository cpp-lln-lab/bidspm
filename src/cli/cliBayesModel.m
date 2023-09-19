function cliBayesModel(varargin)
  % Run stats on bids datasets.
  %
  % Type ``bidspm help`` for more info.
  %

  % TODO make sure that options defined in JSON or passed as a structure
  % overrides any other arguments

  % (C) Copyright 2023 bidspm developers
  args = inputParserForBayesModel();
  try
    parse(args, varargin{:});
  catch ME
    displayArguments(varargin{:});
    rethrow(ME);
  end

  validate(args);

  action = args.Results.action;
  opt = getOptionsFromCliArgument(args);
  opt.pipeline.type = 'stats';
  opt.pipeline.isBms = true;
  opt = checkOptions(opt);

  saveOptions(opt);

  switch action
    case 'bms'
      bidsModelSelection(opt, 'action', 'all');
    case 'bms-posterior'
      bidsModelSelection(opt, 'action', 'posterior');
    case 'bms-bms'
      bidsModelSelection(opt, 'action', 'BMS');
  end

end
