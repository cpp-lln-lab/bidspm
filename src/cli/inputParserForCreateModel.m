function args = inputParserForCreateModel()
  % (C) Copyright 2022 bidspm developers
  args = baseInputParser();

  isEmptyOrCellstr = @(x) isempty(x) || iscellstr(x);  %#ok<*ISCLSTR>

  % :param ignore: Optional. Cell string that can contain:
  %                - ``"Transformations"``
  %                - ``"Contrasts"``
  %                - ``"Dataset"``
  %                Can be used to avoid generating certain objects of the BIDS stats model.
  addParameter(args, 'ignore', {}, isEmptyOrCellstr);

end
