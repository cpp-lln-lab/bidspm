function notImplemented(varargin)
  %
  % USAGE::
  %
  %   notImplemented(functionName, msg, verbose)
  %
  % :param functionName: obligatory argument.
  % :type functionName: path
  % :param msg: optional
  % :type msg: char
  % :param verbose: default ``true``
  % :type verbose: boolean
  %
  % :returns: - :status: (boolean)
  %
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;

  defaultMsg = '';
  defaultVerbose = true;

  logicalOrNumeric = @(x) islogical(x) || isnumeric(x);

  addRequired(p, 'functionName', @ischar);
  addOptional(p, 'msg', defaultMsg, @ischar);
  addOptional(p, 'verbose', defaultVerbose, logicalOrNumeric);

  parse(p, varargin{:});

  tolerant = true;

  errorHandling(p.Results.functionName, 'notImplemented', ...
                p.Results.msg, ...
                tolerant, ...
                p.Results.verbose);

end
