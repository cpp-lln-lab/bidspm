function checkRegressorName(SPM)
  %
  % extra checks for ``bidsModelSelection`` to make sure that:
  %
  %   - all sessions can be vertically concatenated
  %   - after concatenation all regressors have the same name (or that there are dummy regressors)
  %
  % USAGE::
  %
  %  checkRegressorName(SPM)
  %
  %
  % See also: bidsModelSelection
  %
  % (C) Copyright 2022 bidspm developers

  all_columns = {};

  for i_session = 1:numel(SPM.Sess)

    regressors = cat(1, SPM.Sess(i_session).U.name)';
    confounds = SPM.Sess(i_session).C.name;

    all_columns(i_session, :) = cat(2, regressors, confounds);

  end

  for i_col = 1:size(all_columns, 2)
    nbRegressorInThisCol = numel(unique(all_columns(:, i_col)));
    assert(nbRegressorInThisCol <= 2);
    if nbRegressorInThisCol > 2 || ...
      (nbRegressorInThisCol == 2 && ...
       ~any(ismember({'dummyRegressor', 'dummyConfound'}, all_columns(:, i_col))))
      disp(all_columns(:, i_col));
      error('Different regressors in the same column.');
    end
  end

end
