function  createDerivativeDir(opt)
  %
  % Creates the derivative folder if it does not exist.
  %
  % USAGE::
  %
  %   opt = createDerivativeDir(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %

  % (C) Copyright 2019 bidspm developers

  msg = 'derivatives directory already exists. \n';

  if ~exist(opt.dir.derivatives, 'dir')
    spm_mkdir(opt.dir.derivatives);
    msg = sprintf('derivatives directory created: %s', ...
                  pathToPrint(opt.dir.derivatives));
  end

  logger('INFO', msg, 'options', opt, 'filaneme', mfilename);

end
