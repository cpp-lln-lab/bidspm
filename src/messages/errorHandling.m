function errorHandling(varargin)
  %
  % USAGE::
  %
  %  errorHandling(functionName, id, msg, tolerant, verbose)
  %
  % :param functionName:
  % :type functionName: char
  %
  % :param id: Error or warning id
  % :type id: char
  %
  % :param msg: Message to print
  % :type msg: char
  %
  % :param tolerant: If set to ``true`` errors are converted into warnings
  % :type tolerant: boolean
  %
  % :param verbose: If set to ``0`` or ``false`` this will silence any warning
  % :type verbose: boolean
  %
  % EXAMPLE::
  %
  %  msg = sprintf('this error happened with this file %s', filename)
  %  id = 'thisError';
  %  errorHandling(mfilename(), id, msg, true, opt.verbosity)
  %
  %
  % adapted from bids-matlab
  %

  % (C) Copyright 2018 bidspm developers

  defaultFunctionName = 'bidspm';
  defaultId = 'unspecified';
  defaultMsg = 'unspecified';
  defaultTolerant = true;
  defaultVerbose = false;

  args = inputParser;

  addOptional(args, 'functionName', defaultFunctionName, @ischar);
  addOptional(args, 'id', defaultId, @ischar);
  addOptional(args, 'msg', defaultMsg, @ischar);
  addOptional(args, 'tolerant', defaultTolerant, @islogical);
  addOptional(args, 'verbose', defaultVerbose, @(x) (islogical(x) || isnumeric(x)));

  parse(args, varargin{:});

  functionName = spm_file(args.Results.functionName, 'basename');

  id = [functionName, ':' args.Results.id];

  if ~args.Results.tolerant
    errorStruct.identifier = id;
    errorStruct.message = args.Results.msg;
    error(errorStruct);
  end

  if args.Results.verbose > 0
    warning(id, args.Results.msg);
  end

end
