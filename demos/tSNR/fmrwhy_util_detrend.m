function out_data = fmrwhy_util_detrend(data, order)
    % Removes linear and/or quadratic trends from timeseries data
    %
    % INPUT:
    % data    - R x C matrix; R = rows = time points;
    %           C = columns = variables/parameters
    % order   - order (1,2) of regressors in design matrix
    %           order = 1: linear trend
    %           order = 2: linear trend + quadratic trend
    %
    % OUTPUT:
    % out_data
    % __________________________________________________________________________
    % Copyright (C) Stephan Heunis 2018

    % Define variables
    [r, c] = size(data);
    % Create design matrix with model regressors
    if order == 1
        X = (1:r)';
    else
        X = [(1:r)' ((1:r)').^2];
    end
    % Remove mean from design matrix
    X = X - repmat(mean(X, 1), r, 1);
    % Add constant regressor
    X = [ones(r, 1) X];
    % Solve system of linear equations
    b = pinv(X) * data;
    % Detrend data
    data = data - X(:, 2:end) * b(2:end, :);
    out_data = data;