function args = inputParserForCopy()
  % (C) Copyright 2022 bidspm developers
  isLogical = @(x) islogical(x) && numel(x) == 1;
  args = baseInputParser();
  % allow unmatched in case this is called from cliSmooth
  args.KeepUnmatched = true;
  addParameter(args, 'force', false, isLogical);
end
