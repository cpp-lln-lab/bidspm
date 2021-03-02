function [sts, images]= checkOrientation(referenceImage, imagesToCheck)
    
    % referenceImage - better if fullfile path
    % imagesToCheck - better if fullfile path
    
    % TODO
    % - make it possible to pass several images in imagesToCheck at one    
    
    images = char({referenceImage;imagesToCheck});
    
    % check if files are in the same space
    % if not we reslice the ROI to have the same resolution as the data image
    sts = spm_check_orientations(spm_vol(images));
    
end