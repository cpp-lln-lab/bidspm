function args = inputParserForSmooth()
  % Returns an input parser for cliSmooth.
  %
  % Type ``bidspm help`` for more info.
  %

  % (C) Copyright 2022 bidspm developers
  args = inputParserForCopy();

  isPositiveScalar = @(x) isnumeric(x) && numel(x) == 1 && x >= 0;
  isLogical = @(x) islogical(x) && numel(x) == 1;
  isCellStr = @(x) iscellstr(x);

  addParameter(args, 'space', {}, isCellStr);
  addParameter(args, 'fwhm', 6, isPositiveScalar);
  addParameter(args, 'dry_run', false, isLogical);
end
