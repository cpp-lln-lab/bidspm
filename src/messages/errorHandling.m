function errorHandling(varargin)
  %
  % USAGE::
  %
  %  errorHandling(functionName, id, msg, tolerant, verbose)
  %
  % :param functionName:
  % :type functionName: string
  % :param id: Error or warning id
  % :type id: string
  % :param msg: Message to print
  % :type msg: string
  % :param tolerant: If set to ``true`` errors are converted into warnings
  % :type tolerant: boolean
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
  % (C) Copyright 2018 CPP_SPM developers

  defaultFunctionName = 'cpp_spm';
  defaultId = 'unspecified';
  defaultMsg = 'unspecified';
  defaultTolerant = true;
  defaultVerbose = false;

  p = inputParser;

  addOptional(p, 'functionName', defaultFunctionName, @ischar);
  addOptional(p, 'id', defaultId, @ischar);
  addOptional(p, 'msg', defaultMsg, @ischar);
  addOptional(p, 'tolerant', defaultTolerant, @islogical);
  addOptional(p, 'verbose', defaultVerbose, @(x) (islogical(x) || isnumeric(x)));

  parse(p, varargin{:});

  functionName = spm_file(p.Results.functionName, 'basename');

  id = [functionName, ':' p.Results.id];

  if ~p.Results.tolerant
    errorStruct.identifier = id;
    errorStruct.message = p.Results.msg;
    error(errorStruct);
  end

  if p.Results.verbose > 0
    warning(id, p.Results.msg);
  end

end
