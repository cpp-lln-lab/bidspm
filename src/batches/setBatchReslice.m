% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchReslice(matlabbatch, referenceImg, sourceImages, interp)
  %
  % Set the batch for reslicing source images to the reference image resolution
  %
  % USAGE::
  %
  %   matlabbatch = setBatchReslice(matlabbatch, referenceImg, sourceImages, interp = 4)
  %
  % :param matlabbatch: list of SPM batches
  % :type matlabbatch: structure
  % :param referenceImg: Reference image
  % :type referenceImg: string or cellstring
  % :param sourceImages: Source images
  % :type sourceImages: string or cellstring
  %
  %
  % :returns: - :matlabbatch: (structure) The matlabbatch ready to run the spm job
  %

  printBatchName('reslicing');

  if nargin < 4 || isempty(interp)
    interp = 4;
  end
  write.roptions.interp = interp;

  if ischar(referenceImg)
    referenceImg = {referenceImg};
  end
  write.ref(1) = referenceImg;

  if ischar(sourceImages)
    sourceImages = {sourceImages};
  end
  write.source(1) = sourceImages;
  
  matlabbatch{end + 1}.spm.spatial.coreg.write = write;

end
