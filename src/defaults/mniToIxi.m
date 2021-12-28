function opt_out = mniToIxi(varargin)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   opt_out = mniToIxi(opt)
  %
  % :param foo: options
  % :type foo: structure
  %
  % :returns: - :opt_out: (type) (structure)
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  p = inputParser;
  addRequired(p, 'opt', @isstruct);
  parse(p, varargin{:});
  opt = p.Results.opt;

  throwWarning = false;

  if ismember('MNI', opt.space)
    idx = strcmp(opt.space, 'MNI');
    opt.space{idx} = 'IXI549Space';
    throwWarning = true;
  end

  if isfield(opt.query, 'space')
    
    if ~iscell(opt.query.space)
      opt.query.space = {opt.query.space};
    end
    
    if ismember('MNI', opt.query.space)
    idx = strcmp(opt.query.space, 'MNI');
    opt.query.space{idx} = 'IXI549Space';
    throwWarning = true;
    end
  end

  if throwWarning
    msg = sprintf('Converting reference to MNI space tp SPM IXI549Space');
    id = 'mniToIXI549Space';
    errorHandling(mfilename(), id, msg, true, opt.verbosity);
  end

  opt_out = opt;

end
