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

  % (C) Copyright 2022 bidspm developers

  args = inputParser;

  addRequired(args, 'names', @iscellstr);
  addRequired(args, 'R', @isnumeric);
  addRequired(args, 'allConfoundsNames', @iscellstr);

  parse(args, varargin{:});

  names = args.Results.names;
  R = args.Results.R;
  allConfoundsNames = args.Results.allConfoundsNames;

  allConfoundsNames = unique(allConfoundsNames);

  if numel(allConfoundsNames) < numel(names) && not(all(ismember(names, allConfoundsNames)))
    id = 'missingConfounds';
    msg = 'Some of the confounds to reorder are not in the reference list.';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end

  [LIA, LOCB] = ismember(allConfoundsNames, names);

  if all(LIA)
    names = names(LOCB);
    R = R(:, LOCB);

  else
    newR = zeros(size(R, 1), numel(allConfoundsNames));
    newR(:, LIA) = R(:, LOCB(LIA));
    R = newR;

    newNames = repmat({'dummyConfound'}, 1, numel(allConfoundsNames));
    newNames(LIA) = names(LOCB(LIA));
    names = newNames;

  end

end
