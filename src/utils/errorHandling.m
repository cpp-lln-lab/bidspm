function errorHandling(varargin)
  %
  % USAGE::
  %
  %  error_handling(function_name, id, msg, tolerant, verbose)
  %
  %
  % adapted from bids-matlab
  %
  % (C) Copyright 2018 CPP_SPM developers

  default_function_name = 'cpp_spm';
  default_id = 'unspecified';
  default_msg = 'unspecified';
  default_tolerant = true;
  default_verbose = false;

  p = inputParser;

  addOptional(p, 'function_name', default_function_name, @ischar);
  addOptional(p, 'id', default_id, @ischar);
  addOptional(p, 'msg', default_msg, @ischar);
  addOptional(p, 'tolerant', default_tolerant, @islogical);
  addOptional(p, 'verbose', default_verbose, @(x) (islogical(x) || isnumeric(x)));

  parse(p, varargin{:});

  function_name = spm_file(p.Results.function_name, 'basename');

  id = [function_name, ':' p.Results.id];

  if ~p.Results.tolerant
    errorStruct.identifier = id;
    errorStruct.message = p.Results.msg;
    error(errorStruct);
  end

  if p.Results.verbose
    warning(id, p.Results.msg);
  end

end
