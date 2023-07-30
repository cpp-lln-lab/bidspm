function args = inputParserForCreateRoi()
  % Returns an input parser for cliDefaultModel.
  %
  % Type ``bidspm help`` for more info.
  %

  % (C) Copyright 2023 bidspm developers

  % realying on the base parser adds too many options
  % like task
  args = baseInputParser();

  isInAvailableAtlas = @(x) (ischar(x) && ismember(x, supportedAtlases()));
  isChar = @(x) ischar(x);
  isCellStr = @(x) iscellstr(x);
  isLogical = @(x) islogical(x) && numel(x) == 1;

  addParameter(args, 'roi_dir', '', isChar);
  addParameter(args, 'hemisphere', {'L', 'R'}, isCellStr);
  addParameter(args, 'roi_atlas', 'neuromorphometrics', isInAvailableAtlas);
  addParameter(args, 'roi_name', {''}, isCellStr);
  addParameter(args, 'boilerplate_only', false, isLogical);
end
