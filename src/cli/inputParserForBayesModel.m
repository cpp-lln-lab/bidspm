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
  isEmptyOrCellstr = @(x) isempty(x) || iscellstr(x);  %#ok<*ISCLSTR>

  addParameter(args, 'preproc_dir', pwd, isFolder);
  addParameter(args, 'models_dir', pwd, isFolder);

  addParameter(args, 'fwhm', 6, isPositiveScalar);
  addParameter(args, 'dry_run', false, isLogical);
  addParameter(args, 'skip_validation', false, isLogical);

  % :param ignore:      can be any of ``{'qa'}``
  % :type  ignore:      cell string
  addParameter(args, 'ignore', {}, isEmptyOrCellstr);

end
