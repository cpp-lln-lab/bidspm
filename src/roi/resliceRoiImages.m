% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function reslicedImages = resliceRoiImages(referenceImage, imagesToCheck)

  % TODO
  % - make prefix more flexible
  % - make it possible to pass several images in imagesToCheck at one
  % - allow option to binarize output?

  % check if files are in the same space
  % if not we reslice the ROI to have the same resolution as the data image
  [sts, images] = checkRoiOrientation(referenceImage, imagesToCheck);
  if sts == 1
    reslicedImages = imagesToCheck;

  else

    flags = struct( ...
                   'mean', false, ...
                   'which', 1, ...
                   'prefix', 'r');

    spm_reslice(images, flags);

    basename = spm_file(imagesToCheck, 'basename');
    reslicedImages = spm_file(imagesToCheck, 'basename', [flags.prefix basename]);

  end

end
