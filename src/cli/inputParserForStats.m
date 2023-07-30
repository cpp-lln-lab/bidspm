function args = inputParserForStats()
  % (C) Copyright 2022 bidspm developers
  args = baseInputParser();

  isInAvailableAtlas = @(x) (ischar(x) && ismember(x, supportedAtlases()));
  isFileOrStruct = @(x) isstruct(x) || exist(x, 'file') == 2;
  isLogical = @(x) islogical(x) && numel(x) == 1;
  isChar = @(x) ischar(x);
  isPositiveScalar = @(x) isnumeric(x) && numel(x) == 1 && x >= 0;
  isFolder = @(x) isdir(x);
  isCellStr = @(x) iscellstr(x);

  addParameter(args, 'fwhm', 6, isPositiveScalar);
  addParameter(args, 'dry_run', false, isLogical);
  addParameter(args, 'skip_validation', false, isLogical);
  addParameter(args, 'boilerplate_only', false, isLogical);

  addParameter(args, 'preproc_dir', pwd, isFolder);
  addParameter(args, 'model_file', struct([]), isFileOrStruct);

  addParameter(args, 'design_only', false, isLogical);
  addParameter(args, 'concatenate', false, isLogical);
  addParameter(args, 'keep_residuals', false, isLogical);

  addParameter(args, 'roi_atlas', 'neuromorphometrics', isInAvailableAtlas);

  addParameter(args, 'roi_based', false, isLogical);
  addParameter(args, 'roi_dir', '', isChar);
  addParameter(args, 'roi_name', {''}, isCellStr);

  % group level stats only
  addParameter(args, 'node_name', '', isChar);
end
