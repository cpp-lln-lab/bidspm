function mask = createROI(globalRoiImage)
    
    % roiImage: fullpath of the roiImage

    %% % global roi
    mask.global.hdr = spm_vol(globalRoiImage);
    mask.global.img = logical(spm_read_vols(mask.global.hdr));
    
    [X, Y, Z] = ind2sub(size(mask.global.img), find(mask.global.img));
    
    % XYZ format
    mask.global.XYZ = [X'; Y'; Z']; 
    mask.global.size = size(mask.global.XYZ, 2);
    
    % voxel to world transformation
    mask.global.XYZmm = mask.global.hdr.mat(1:3,:) ...
        * [mask.global.XYZ; ones(1, mask.global.size)]; 
    
    
    if nargin<2
        xY.def = 'mask';
        xY.spec = globalRoiImage;
        [xY, mask.roi.XYZmm, j] = spm_ROI(xY, mask.global.XYZmm);
        mask.roi.XYZ = mask.global.XYZ(:,j);
        mask.roi.size = size(mask.roi.XYZ, 2);
        return
    end
    
%     %% 
%     for i=1:length(Mask.ROI)
%         Mask.ROI(i).hdr = spm_vol(fullfile(RoiFolder, Mask.ROI(i).fname));
%     end
%     
%     
%     %% Combine masks
%     xY.def = 'mask';
%     for i=1:length(Mask.ROI)
%         xY.spec = fullfile(RoiFolder, Mask.ROI(i).fname);
%         [xY, Mask.ROI(i).XYZmm, j] = spm_ROI(xY, Mask.global.XYZmm);
%         Mask.ROI(i).XYZ = Mask.global.XYZ(:,j);
%         Mask.ROI(i).size = size(Mask.ROI(i).XYZ, 2);
%     end
    
end