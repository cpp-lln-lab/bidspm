function printToScreen(msg, opt)
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  if nargin < 2 || opt.verbosity

    fprintf(1, msg);

  end

end
