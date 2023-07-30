function args = inputParserForCreateModel()
  % Returns an input parser for cliDefaultModel.
  %
  % Type ``bidspm help`` for more info.
  %

  % (C) Copyright 2023 bidspm developers
  args = baseInputParser();

  isEmptyOrCellstr = @(x) isempty(x) || iscellstr(x);  %#ok<*ISCLSTR>

  % realying on the base parser adds too many options
  % like task

  % :param ignore: Optional. Cell string that can contain:
  %                - ``"Transformations"``
  %                - ``"Contrasts"``
  %                - ``"Dataset"``
  %                Can be used to avoid generating certain objects of the BIDS stats model.
  addParameter(args, 'ignore', {}, isEmptyOrCellstr);

end
