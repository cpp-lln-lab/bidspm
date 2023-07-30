function [names, R] = sanitizeConfounds(names, R)
  %
  % Removes columns with same content from confounds
  %
  %
  % USAGE::
  %
  %   [names, R] = sanitizeConfounds(names, R)
  %
  % :param names: name of each confound
  % :type  names: cell string
  %
  % :param R: n x m confounds matrix (n: nb timepoint, m: nb confounds)
  % :type  R: array
  %
  %
  % :returns: :names:
  % :returns: :R:

  % (C) Copyright 2023 bidspm developers

  %   TODO should not remove duplicate confounds when doing model comparison

  idx_col_to_rm = [];
  for col = 1:(size(R, 2) - 1)
    ref = R(:, col);
    for iTestCol = (col + 1):size(R, 2)
      test = R(:, iTestCol);
      if all(test == ref)
        dupes = bids.internal.create_unordered_list( ...
                                                    names([col, iTestCol]));
        msg = sprintf('\nDuplicate counfounds:%s', dupes);
        logger('WARNING', msg, ...
               'filename', mfilename(), ...
               'id', 'duplicatConfounds');
        idx_col_to_rm(end + 1) = col; %#ok<*AGROW>
      end
    end
  end

  if ~isempty(idx_col_to_rm)
    R(:, idx_col_to_rm) = [];
    names(idx_col_to_rm) = [];
  end

end
