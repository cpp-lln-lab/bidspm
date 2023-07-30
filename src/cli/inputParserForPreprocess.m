function args = inputParserForPreprocess()
  % Returns an input parser for cliPreprocess.
  %
  % Type ``bidspm help`` for more info.
  %

  % (C) Copyright 2022 bidspm developers
  args = baseInputParser();

  isPositiveScalar = @(x) isnumeric(x) && numel(x) == 1 && x >= 0;
  isLogical = @(x) islogical(x) && numel(x) == 1;
  isEmptyOrCellstr = @(x) isempty(x) || iscellstr(x);  %#ok<*ISCLSTR>

  addParameter(args, 'fwhm', 6, isPositiveScalar);
  addParameter(args, 'dry_run', false, isLogical);
  addParameter(args, 'anat_only', false, isLogical);
  addParameter(args, 'dummy_scans', 0, isPositiveScalar);
  % :param ignore:      can be any of ``{'fieldmaps', 'slicetiming', 'unwarp', 'qa'}``
  % :type  ignore:      cell string
  addParameter(args, 'ignore', {}, isEmptyOrCellstr);
  addParameter(args, 'skip_validation', false, isLogical);
  addParameter(args, 'boilerplate_only', false, isLogical);
end
