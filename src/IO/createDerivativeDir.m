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
  %             See  also: checkOptions
  % :type opt: structure
  %
  % (C) Copyright 2019 CPP_SPM developers

  msg = 'derivatives directory already exists. \n';

  if ~exist(opt.dir.derivatives, 'dir')
    spm_mkdir(opt.dir.derivatives);
    msg = sprintf('derivatives directory created: %s \n', ...
                  pathToPrint(opt.dir.derivatives));
  end

  printToScreen(msg, opt);

end
