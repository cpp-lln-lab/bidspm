function matlabbatch = setBatchSmoothing(matlabbatch, opt, images, fwhm, prefix)
  %
  % Small wrapper to create smoothing batch
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSmoothing(matlabbatch, opt, images, fwhm, prefix)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %
  % :param images:
  % :type images: fullpath
  %
  % :param fwhm:
  % :type fwhm: positive integer
  %
  % :param prefix:
  % :type prefix: char
  %
  % :returns: - :matlabbatch: (structure)
  %
  %
  % See also: bidsSmoothing, bidsRFX, setBatchSmoothingFunc, setBatchSmoothConImages
  %
  %

  % (C) Copyright 2019 bidspm developers

  printBatchName('smoothing images', opt);

  matlabbatch{end + 1}.spm.spatial.smooth.data = images;
  matlabbatch{end}.spm.spatial.smooth.prefix = prefix;
  matlabbatch{end}.spm.spatial.smooth.fwhm = [fwhm fwhm fwhm];

  matlabbatch{end}.spm.spatial.smooth.dtype = 0;
  matlabbatch{end}.spm.spatial.smooth.im = 0;

end
