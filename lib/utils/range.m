function y = range(x,dim)
% Sample range.
%
% USAGE::
%
%   Y = range(X) returns the range of the values in X.
%
%   For a vector input, Y is the difference between the maximum and minimum values
%   For a matrix input, Y is a vector containing the range for each column.
%   For N-D arrays, range operates along the first non-singleton dimension.
%
%   range treats NaNs as missing values, and ignores them.
%
%   Y = range(X,DIM) operates along the dimension DIM.
%


if nargin < 2
    y = max(x) - min(x);
else
    y = max(x,[],dim) - min(x,[],dim);
end
