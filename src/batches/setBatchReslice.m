% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchReslice(matlabbatch, referenceImg, sourceImages, interp)
  %
  % Set the batch for reslicing source images into the reference image???
  %
  % USAGE::
  %
  %   matlabbatch = setBatchReslice(matlabbatch, referenceImg, sourceImages)
  %
  % :param matlabbatch: list of SPM batches
  % :type matlabbatch: structure
  % :param referenceImg: Reference image
  % :type referenceImg: string
  % :param sourceImages: Source images
  % :type sourceImages: cell
  %
  %
  % :returns: - :matlabbatch: (structure) The matlabbatch ready to run the spm job
  %

  printBatchName('reslicing');

  if nargin < 4 || isempty(interp)
    interp = 4;
  end

  matlabbatch{end + 1}.spm.spatial.coreg.write.roptions.interp = interp;

  if ischar(referenceImg)
    matlabbatch{end}.spm.spatial.coreg.write.ref = {referenceImg};

  else
    matlabbatch{end}.spm.spatial.coreg.write.ref(1) = referenceImg;
  end

  if iscell(sourceImages)
    matlabbatch{end}.spm.spatial.coreg.write.source = sourceImages;

  else
    matlabbatch{end}.spm.spatial.coreg.write.source(1) = referenceImg;
  end

end
