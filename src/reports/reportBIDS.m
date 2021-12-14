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

  bids.report(opt.dir.raw);

  bids.report(opt.dir.raw, ...
              'output_path', pwd, ...
              'read_nifti', true, ...
              'verbose', true);

end
