% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchReslice(matlabbatch, referenceImg, sourceImages)
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

  if ischar(referenceImg)
    matlabbatch{end + 1}.spm.spatial.coreg.write.ref = {referenceImg};

  elseif isstruct(referenceImg)
  end

  if iscell(sourceImages)
    matlabbatch{1}.spm.spatial.coreg.write.source = sourceImages;

  elseif isstruct(sourceImages)
  end

end
