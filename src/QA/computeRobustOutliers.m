function outliers = computeRobustOutliers(varargin)
  %
  % Computes robust ouliers of a time series using S-outliers or Carling's k
  %
  %
  % EXAMPLE::
  %
  %     outliers = spmup_comp_robust_outliers(time_series, 'outlierType', 'Carling')
  %
  %
  % :param timeSeries: time_series are the time courses as colum vectors
  % :type  timeSeries: n X m array
  %
  % :param outlierType: any of 'S-outliers' or 'Carling'.
  %                     Default to 'Carling'.
  % :type  outlierType: char
  %
  % OUTPUT
  %
  % Uutliers a binary vector indicating outliers.
  %
  % S-outliers is the default options, it is independent of a mesure of
  % centrality as this is based on the median of pair-wise distances.
  % This is a very sensitive measures,
  % i.e. it has a relatively high false positive rates.
  % As such it is a great detection tools.
  %
  % The adjusted Carling's box-plot rule can also be used,
  % and derived from the median of the data:
  % outliers are outside the bound of median+/- k*IQR,
  % with k = (17.63*n-23.64)/(7.74*n-3.71).
  % This is a more specific measure, as such it is 'better'
  % than S-outliers to regress-out, removing bad data points
  % (assuming we don't want to 'remove' too many).
  %
  % References:
  %
  %     - Rousseeuw, P. J., and Croux, C. (1993). Alternatives to the the median
  %       absolute deviation. J. Am. Stat. Assoc. 88, 1273-1263.
  %       <https://www.tandfonline.com/doi/abs/10.1080/01621459.1993.10476408>
  %
  %     - Carling, K. (2000). Resistant outlier rules and the non-Gaussian case.
  %       Stat. Data Anal. 33, 249:258.
  %       <http://www.sciencedirect.com/science/article/pii/S0167947399000572>
  %
  %     - Hoaglin, D.C., Iglewicz, B. (1987) Fine-tuning some resistant rules for
  %       outlier labelling. J. Amer. Statist. Assoc., 82 , 1147:1149
  %       <http://www.tandfonline.com/doi/abs/10.1080/01621459.1986.10478363>
  %
  % Adapted from Cyril Pernet's spmup
  %

  % (C) Copyright 2023 Cyril Pernet
  % (C) Copyright 2023 Remi Gau

  allowedTypes = @(x) ismember(lower(x), {'carling', 's-outliers'});

  args = inputParser;
  addRequired(args, 'timeSeries');
  addParameter(args, 'outlierType', 'Carling', allowedTypes);

  parse(args, varargin{:});

  timeSeries = args.Results.timeSeries;
  outlierType = args.Results.outlierType;

  flip = 0;
  % in case input is a single row vector
  if size(timeSeries, 1) == 1
    flip = 1;
    timeSeries = timeSeries';
  end

  if strcmpi(outlierType, 'S-outliers')
    k = sqrt(chi2inv(0.975, 1));
    for p = size(timeSeries, 2):-1:1
      tmp = timeSeries(:, p);
      points = find(~isnan(tmp));
      tmp(isnan(tmp)) = [];

      % compute all distances
      n = length(tmp);
      for i = n:-1:1
        j = points(i);
        indices = 1:n;
        % all but current data point
        indices(i) = [];
        % median of all pair-wise distances
        distance(j, p) = median(abs(tmp(i) - tmp(indices)));
      end

      % get the S estimator
      % consistency factor c = 1.1926;
      Sn = 1.1926 * median(distance(points, p));

      % get the outliers in a normal distribution

      % no scaling needed as S estimates already std(data)
      outliers(:, p) = (distance(:, p) ./ Sn) > k;
      outliers(:, p) = outliers(:, p) + isnan(timeSeries(:, p));
    end

  elseif strcmpi(outlierType, 'Carling')

    % interquartile range
    n = size(timeSeries, 1);
    y = sort(timeSeries);
    j = floor(n / 4 + 5 / 12);
    g = (n / 4) - j + (5 / 12);
    k = n - j + 1;

    % lower quartiles
    lowerQuartile = (1 - g) .* y(j, :) + g .* y(j + 1, :);
    % higher quartiles
    upperQuartile = (1 - g) .* y(k, :) + g .* y(k - 1, :);
    % inter-quartiles range
    values = upperQuartile - lowerQuartile;

    % robust outliers
    M = median(timeSeries);
    CarlinK = (17.63 * n - 23.64) / (7.74 * n - 3.71); % Carling's k
    outliers = timeSeries < (M - CarlinK * values) | ...
               timeSeries > (M + CarlinK * values);

  end

  if flip == 1
    outliers = outliers';
  end

end
