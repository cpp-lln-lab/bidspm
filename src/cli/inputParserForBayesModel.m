function args = inputParserForBayesModel()
  % Returns an input parser for cliSBayesModel
  %
  % Type ``bidspm help`` for more info.
  %

  % (C) Copyright 2022 bidspm developers
  args = baseInputParser();

  isLogical = @(x) islogical(x) && numel(x) == 1;
  isPositiveScalar = @(x) isnumeric(x) && numel(x) == 1 && x >= 0;
  isFolder = @(x) isdir(x);

  addParameter(args, 'models_dir', pwd, isFolder);

  addParameter(args, 'fwhm', 6, isPositiveScalar);
  addParameter(args, 'dry_run', false, isLogical);
  addParameter(args, 'skip_validation', false, isLogical);

end
