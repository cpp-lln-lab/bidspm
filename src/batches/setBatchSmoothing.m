function matlabbatch = setBatchSmoothing(matlabbatch, images, FWHM, prefix)
  %
  % Small wrapper to create smoothing batch
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSmoothing(matlabbatch, images, FWHM, prefix)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param images:
  % :type images:
  % :param funcFWHM:
  % :type funcFWHM:
  % :param prefix:
  % :type prefix:
  %
  % :returns: - :matlabbatch: (structure)
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  printBatchName('smoothing images');

  matlabbatch{end + 1}.spm.spatial.smooth.data = images;
  matlabbatch{end}.spm.spatial.smooth.prefix = prefix;
  matlabbatch{end}.spm.spatial.smooth.fwhm = [FWHM FWHM FWHM];

  matlabbatch{end}.spm.spatial.smooth.dtype = 0;
  matlabbatch{end}.spm.spatial.smooth.im = 0;

end
