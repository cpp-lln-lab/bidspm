function notImplemented(varargin)
  %
  % USAGE::
  %
  %   notImplemented(functionName, msg, verbose)
  %
  % :param opt: obligatory argument.
  % :type opt: structure
  % :param roiList: obligatory argument.
  % :type roiList: cell
  % :param folder: optional argument. default: ``''``
  % :type folder: path
  %
  % :returns: - :status: (boolean)
  %
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;

  defaultMsg = '';
  defaultVerbose = true;

  addRequired(p, 'functionName', @ischar);
  addOptional(p, 'msg', defaultMsg, @ischar);
  addOptional(p, 'verbose', defaultVerbose, @islogical);

  parse(p, varargin{:});

  tolerant = true;

  errorHandling(p.Results.functionName, 'notImplemented', ...
                p.Results.msg, ...
                tolerant, ...
                p.Results.verbose);

end
