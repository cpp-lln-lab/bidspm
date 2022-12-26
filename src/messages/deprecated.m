function deprecated(varargin)
  %
  % Throws a deprecation warning
  %
  % USAGE::
  %
  %   deprecated(functionName)
  %
  % :param functionName: obligatory argument.
  % :type  functionName: path
  %
  %

  % (C) Copyright 2022 bidspm developers

  args = inputParser;

  addRequired(args, 'functionName', @ischar);

  parse(args, varargin{:});

  logger('WARNING', ...
         'This function is deprecated and will be removed in the next major update.', ...
         'filename', args.Results.functionName, ...
         'id', 'deprecated');

end
