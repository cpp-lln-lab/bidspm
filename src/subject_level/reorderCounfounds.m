function [names, R] = reorderCounfounds(varargin)
  %
  %
  % USAGE::
  %
  %   [names, R] = reorderCounfounds(names, R, allConfoundsNames)
  %
  % :param names: obligatory argument.
  % :type names: cell
  %
  % :param R: obligatory argument.
  % :type R: array
  %
  % :param allConfoundsNames: obligatory argument.
  % :type allConfoundsNames: cell
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  args = inputParser;

  addRequired(args, 'names', @iscellstr);
  addRequired(args, 'R', @isnumeric);
  addRequired(args, 'allConfoundsNames', @iscellstr);

  parse(args, varargin{:});

  names = args.Results.names;
  R = args.Results.R;
  allConfoundsNames = args.Results.allConfoundsNames;

  [LIA, LOCB] = ismember(allConfoundsNames, names);

  names = names(LOCB);
  R = R(:, LOCB);

end
