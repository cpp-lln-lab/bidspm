function optOut = mniToIxi(varargin)
  %
  % Convert mention of MNI space to the SPM default space IXI549Space
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
  % (C) Copyright 2021 bidspm developers

  args = inputParser;
  addRequired(args, 'opt', @isstruct);
  parse(args, varargin{:});
  opt = args.Results.opt;

  throwWarning = false;

  if isfield(opt, 'space') && ismember('MNI', opt.space)
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

  optOut = opt;

end
