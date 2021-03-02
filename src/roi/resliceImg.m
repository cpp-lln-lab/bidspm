function reslicedImages = resliceImg(referenceImage, imagesToCheck)
    
    % TODO
    % - make prefix more flexible
    % - make it possible to pass several images in imagesToCheck at one
    % - allow option to binarize output?
    
    flags = struct(...
        'mean', false, ...
        'which', 1,...
        'prefix', 'r');
    
    images = char({referenceImage;imagesToCheck});
    
    % check if files are in the same space
    % if not we reslice the ROI to have the same resolution as the data image
    sts = spm_check_orientations(spm_vol(images));
    if sts==1
        reslicedImages = imagesToCheck;
        
    else
        spm_reslice(images,flags);
        
        basename = spm_file(imagesToCheck, 'basename');
        reslicedImages = spm_file(imagesToCheck, 'basename', [flags.prefix basename]);
        
    end

end

