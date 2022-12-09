function notImplemented(varargin)
  %
  % Throws a not implemented warning
  %
  % USAGE::
  %
  %   notImplemented(functionName, msg)
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

  parse(args, varargin{:});

  logger('WARNING', args.Results.msg, ...
         'filename', args.Results.functionName, ...
         'id', 'notImplemented');

end
