function notImplemented(varargin)
  %
  % Throws a not implemented warning
  %
  % USAGE::
  %
  %   notImplemented(functionName, msg, verbose)
  %
  % :param functionName: obligatory argument.
  % :type functionName: path
  %
  % :param msg: optional
  % :type msg: char
  %
  % :param verbose: default ``true``
  % :type verbose: boolean
  %
  % :returns: - :status: (boolean)
  %
  % EXAMPLE::
  %
  %     notImplemented(mfilename(), ...
  %                    'Meaning of life the universe and everything not impemented', ...
  %                    true);
  %

  % (C) Copyright 2022 bidspm developers

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
