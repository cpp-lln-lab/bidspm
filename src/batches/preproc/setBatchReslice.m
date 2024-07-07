function matlabbatch = setBatchReslice(matlabbatch, opt, referenceImg, sourceImages, interp)
  %
  % Set the batch for reslicing source images to the reference image resolution
  %
  % USAGE::
  %
  %   matlabbatch = setBatchReslice(matlabbatch, opt, referenceImg, sourceImages, interp)
  %
  % :param matlabbatch: list of SPM batches
  % :type  matlabbatch: structure
  %
  % :type  opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :param referenceImg: Reference image (only one image)
  % :type  referenceImg: char or cellstring
  %
  % :param sourceImages: Source images
  % :type  sourceImages: char or cellstring
  %
  % :param interp: type of interpolation to use (default = ``4``). Nearest
  %                neighbour = ``0``.
  % :type  interp: integer >= 0
  %
  % :return: matlabbatch, The matlabbatch ready to run the spm job
  % :rtype: structure
  %

  % (C) Copyright 2020 bidspm developers

  printBatchName('reslicing', opt);

  if nargin < 5 || isempty(interp)
    interp = 4;
  end
  write.roptions.interp = interp;

  if ischar(referenceImg)
    referenceImg = {referenceImg};
  end
  write.ref(1) = referenceImg;

  if ischar(sourceImages)
    write.source = {sourceImages};
  elseif iscell(sourceImages)
    write.source = sourceImages;
  end

  matlabbatch{end + 1}.spm.spatial.coreg.write = write;

end
