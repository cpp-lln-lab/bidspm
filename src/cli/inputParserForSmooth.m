function args = inputParserForSmooth()
  % (C) Copyright 2022 bidspm developers
  args = inputParserForCopy();

  isPositiveScalar = @(x) isnumeric(x) && numel(x) == 1 && x >= 0;
  isLogical = @(x) islogical(x) && numel(x) == 1;

  addParameter(args, 'fwhm', 6, isPositiveScalar);
  addParameter(args, 'dry_run', false, isLogical);
  addParameter(args, 'anat_only', false, isLogical);
end
