function args = inputParserForCreateModel()
  % Returns an input parser for cliDefaultModel.
  %
  % Type ``bidspm help`` for more info.
  %

  % (C) Copyright 2023 bidspm developers
  args = baseInputParser();

  isLogical = @(x) islogical(x) && numel(x) == 1;
  isEmptyOrCellstr = @(x) isempty(x) || iscellstr(x);  %#ok<*ISCLSTR>
  isCellStr = @(x) iscellstr(x);

  addParameter(args, 'space', {}, isCellStr);
  addParameter(args, 'task', {}, isEmptyOrCellstr);

  % :param ignore: Optional. Cell string that can contain:
  %                - ``"Transformations"``
  %                - ``"Contrasts"``
  %                - ``"Dataset"``
  %                Can be used to avoid generating certain objects of the BIDS stats model.
  addParameter(args, 'ignore', {}, isEmptyOrCellstr);
  addParameter(args, 'skip_validation', false, isLogical);

end
