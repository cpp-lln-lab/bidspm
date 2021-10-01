function reportBIDS(opt)
  %
  % Prints out a human readable description of a BIDS data set.
  %
  % USAGE::
  %
  %   reportBIDS(opt)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  %
  % .. TODO:
  %
  %     - save output in the derivatires folder
  %       derivativeDir = fullfile(rawDir, '..', 'derivatives', 'cpp_spm');
  %
  % (C) Copyright 2020 CPP_SPM developers

  warning('bidsReport is broken and waiting for a fix on the bids-matlab side.');

  return

  bids.report(opt.dir.raw);

end
