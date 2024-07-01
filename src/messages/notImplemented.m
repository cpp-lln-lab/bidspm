function notImplemented(varargin)
  %
  % Throws a not implemented warning
  %
  % USAGE::
  %
  %   notImplemented(functionName, msg, opt)
  %
  % :param functionName: obligatory argument.
  % :type  functionName: path
  %
  % :param msg: optional
  % :type  msg: char
  %
  % :param opt:
  % :type  opt: struct
  %
  % :return: :status: (boolean)
  %
  % EXAMPLE::
  %
  %     notImplemented(mfilename(), ...
  %                    'Meaning of life the universe and everything not impemented', ...
  %                    opt);
  %

  % (C) Copyright 2022 bidspm developers

  defaultOpt = struct('verbosity', 2);

  args = inputParser;

  addRequired(args, 'functionName', @ischar);
  addRequired(args, 'msg', @ischar);
  addOptional(args, 'opt', defaultOpt, @isstruct);

  parse(args, varargin{:});

  logger('WARNING', args.Results.msg, ...
         'filename', args.Results.functionName, ...
         'id', 'notImplemented', ...
         'options', args.Results.opt);

end
