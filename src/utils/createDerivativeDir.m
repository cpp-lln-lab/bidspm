% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

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

  if ~exist(opt.derivativesDir, 'dir')
    mkdir(opt.derivativesDir);
    fprintf('derivatives directory created: %s \n', opt.derivativesDir);
  else
    fprintf('derivatives directory already exists. \n');
  end

end
