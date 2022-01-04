function [I] = iqr_method(a, out)
    %
    % Returns a logical vector that flags outliers as 1s based
    % on the IQR (interquantile range) methods described in Wilcox 2012 p 96-97.
    %
    % Uses Carling's modification of the boxplot rule.
    %
    % An observation Xi is declared an outlier if:
    %
    %   Xi<M-k(q2-q1) or Xi>M+k(q2-q1)
    %
    % where:
    %  - M is the sample median
    %  - k = (17.63n - 23.64) / (7.74n - 3.71),
    %   - where n is the sample size.
    %
    % INPUT a is a vector of data
    %       out determines the thresholding 1 bilateral 2 unilateral
    %
    % OUTPUTS: I =     logical vector with 1s for outliers
    %          value = IQR, the inter-quartile range
    %
    % Cyril Pernet - spmup - adapted from Corr_toolbox
    % https://github.com/CPernet/spmup
    % ----------------------------------------
    % (C) Copyright 2016 Cyril Pernet

    if nargin == 1
        out = 1;
    end

    a = a(:);
    n = length(a);

    % inter-quartile range
    j = floor(n / 4 + 5 / 12);

    y = sort(a);

    g = (n / 4) - j + (5 / 12);

    q1 = (1 - g) .* y(j) + g .* y(j + 1);

    k = n - j + 1;
    q2 = (1 - g) .* y(k) + g .* y(k - 1);

    value = q2 - q1;

    % outliers
    M = median(a);
    k = (17.63 * n - 23.64) / (7.74 * n - 3.71);
    if out == 1
        I = a < (M - k * value) | a > (M + k * value);
    else
        I = a > (M + k * value); % only reject data with a too high value
    end
    I = I + isnan(a);

end
