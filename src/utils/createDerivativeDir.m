function  createDerivativeDir(opt)
  %
  % Creates the derivative folder if it does not exist.
  %
  % USAGE::
  %
  %   opt = createDerivativeDir(opt)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % (C) Copyright 2019 CPP_SPM developers

  if ~exist(opt.dir.derivatives, 'dir')
    spm_mkdir(opt.dir.derivatives);
    fprintf('derivatives directory created: %s \n', opt.dir.derivatives);
  else
    fprintf('derivatives directory already exists. \n');
  end

end
