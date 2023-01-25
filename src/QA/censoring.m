function censoringRegressors = censoring(data)
  %
  % routine that computes robust outliers for each column of the data in
  % and return a matrix of censsoring regressors (0s and a 1 per column)
  %
  % EXAMPLE::
  %
  %     censoringRegressors = censoring(data)
  %
  % INPUT  data is a n volumes * m matrix to censor column wise
  %
  % OUTPUT censoring_regressors matrix with ones in each column for
  %        outliers found in coumns of data
  %
  %
  % Adapted from Cyril Pernet's spmup

  % (C) Copyright 2017-2023 Cyril Pernet
  % (C) Copyright 2023 Remi Gau

  %% get outliers
  censoringRegressors = [];
  if isempty(data)
    return
  end

  outliers = computeRobustOutliers(data, 'outlierType', 'Carling');

  % create the motion censoring regressors simply diagonalizing
  % each outlier columns and then removing empty columns
  censoringRegressors = [];
  for column = size(outliers, 2):-1:1
    censoringRegressors = [censoringRegressors diag(outliers(:, column))]; %#ok<*AGROW>
  end

  % remove empty columns
  censoringRegressors(:, sum(censoringRegressors, 1) == 0) = [];
  % check a volume is not indexed twice
  for r = 1:size(censoringRegressors, 1)
    rep = find(censoringRegressors(r, :));
    if length(rep) > 1
      censoringRegressors(r, rep(2:end)) = 0;
    end
  end
  censoringRegressors(:, sum(censoringRegressors, 1) == 0) = [];

end
