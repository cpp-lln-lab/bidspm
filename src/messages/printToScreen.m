function printToScreen(varargin)
  %
  % USAGE::
  %
  %   printToScreen(msg, opt, 'format', 'blue')
  %
  % (C) Copyright 2021 CPP_SPM developers

  p = inputParser;

  default_opt = struct('verbosity', 2);
  default_format = 'blue';

  addRequired(p, 'msg', @ischar);
  addOptional(p, 'opt', default_opt, @isstruct);
  addParameter(p, 'format', default_format, @ischar);

  parse(p, varargin{:});

  msg = p.Results.msg;
  opt = p.Results.opt;
  format = p.Results.format;

  if isfield(opt, 'msg') && ~strcmp(opt.msg.color, '')
    format = opt.msg.color;
  end

  if opt.verbosity > 1

    if isOctave()
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
