function args = inputParserForCopy()
  % Returns an input parser for cliCopy.
  %
  % Type ``bidspm help`` for more info.
  %

  % (C) Copyright 2023 bidspm developers
  isLogical = @(x) islogical(x) && numel(x) == 1;

  args = baseInputParser();

  % allow unmatched in case this is called from cliSmooth
  args.KeepUnmatched = true;

  addParameter(args, 'force', false, isLogical);
  addParameter(args, 'anat_only', false, isLogical);
end
