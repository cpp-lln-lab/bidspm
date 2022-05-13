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

  args = inputParser;

  defaultMsg = '';
  defaultVerbose = true;

  logicalOrNumeric = @(x) islogical(x) || isnumeric(x);

  addRequired(args, 'functionName', @ischar);
  addOptional(args, 'msg', defaultMsg, @ischar);
  addOptional(args, 'verbose', defaultVerbose, logicalOrNumeric);

  parse(args, varargin{:});

  tolerant = true;

  errorHandling(args.Results.functionName, 'notImplemented', ...
                args.Results.msg, ...
                tolerant, ...
                args.Results.verbose);

end
