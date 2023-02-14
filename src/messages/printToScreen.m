function printToScreen(varargin)
  %
  % USAGE::
  %
  %   printToScreen(msg, opt, 'format', 'blue')
  %

  % (C) Copyright 2021 bidspm developers

  args = inputParser;

  defaultOpt = struct('verbosity', 2);
  defaultFormat = 'blue';

  addRequired(args, 'msg', @ischar);
  addOptional(args, 'opt', defaultOpt, @isstruct);
  addParameter(args, 'format', defaultFormat);

  parse(args, varargin{:});

  msg = args.Results.msg;
  opt = args.Results.opt;
  format = args.Results.format;

  if isfield(opt, 'msg') && ~strcmp(opt.msg.color, '')
    format = opt.msg.color;
  end

  if opt.verbosity > 1

    if bids.internal.is_octave()
      fprintf(1, msg);
    else
      try
        cprintf(format, msg);
      catch
        fprintf(1, msg);
      end
    end

  end

end
