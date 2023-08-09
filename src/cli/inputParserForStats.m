function args = inputParserForStats()
  % Returns an input parser for cliStats.
  %
  % Type ``bidspm help`` for more info.
  %

  % (C) Copyright 2022 bidspm developers
  args = baseInputParser();

  isInAvailableAtlas = @(x) (ischar(x) && ismember(x, supportedAtlases()));
  isFileOrStructOrIsDir = @(x) isstruct(x) || exist(x, 'file') == 2 || isdir(x);
  isLogical = @(x) islogical(x) && numel(x) == 1;
  isChar = @(x) ischar(x);
  isPositiveScalar = @(x) isnumeric(x) && numel(x) == 1 && x >= 0;
  isFolder = @(x) isdir(x);
  isCellStr = @(x) iscellstr(x);
  isEmptyOrCellstr = @(x) isempty(x) || iscellstr(x);  %#ok<*ISCLSTR>

  addParameter(args, 'task', {}, isCellStr);
  addParameter(args, 'preproc_dir', pwd, isFolder);
  addParameter(args, 'model_file', struct([]), isFileOrStructOrIsDir);

  addParameter(args, 'fwhm', 6, isPositiveScalar);
  addParameter(args, 'dry_run', false, isLogical);
  addParameter(args, 'skip_validation', false, isLogical);
  addParameter(args, 'boilerplate_only', false, isLogical);

  addParameter(args, 'design_only', false, isLogical);
  addParameter(args, 'concatenate', false, isLogical);
  addParameter(args, 'keep_residuals', false, isLogical);

  addParameter(args, 'roi_atlas', 'neuromorphometrics', isInAvailableAtlas);

  addParameter(args, 'roi_based', false, isLogical);
  addParameter(args, 'roi_dir', '', isChar);
  addParameter(args, 'roi_name', {''}, isCellStr);

  % :param ignore:      can be any of ``{'qa'}``
  % :type  ignore:      cell string
  addParameter(args, 'ignore', {}, isEmptyOrCellstr);

  % group level stats only
  addParameter(args, 'node_name', '', isChar);
end
