function printToScreen(msg, opt)
  %
  % USAGE::
  %
  %   printToScreen(msg, opt)
  %
  % (C) Copyright 2021 CPP_SPM developers

  if nargin < 2 || ~isfield(opt, 'verbosity') || opt.verbosity > 1

    fprintf(1, msg);

  end

end
