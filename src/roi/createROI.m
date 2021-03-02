function mask = createROI(type, varargin)
    
    % roiImage:
    %           - fullpath of the roi image
    %           - structure with:
    %               sphere.location = location; % X Y Z coordinates in millimeters
    %               sphere.radius = radius; % radius in millimeters
    
    mask = struct('roi', struct('XYZmm', ''));
    
    switch type
        
        case 'sphere'
            
%             LocationsToSample = varargin{1};
            specification = varargin{1};
            
            xY.def = type;
            xY.spec = specification.radius;
            xY.xyz = specification.location;
            
            if size(xY.xyz,1)~=3
                xY.xyz = xY.xyz';
            end
            
            mask = spm_ROI(xY);

        case 'mask'
            
            roiImage = varargin{1};
            
            xY.def = type;
            xY.spec = roiImage;
           
            mask = defineGlobalSearchSpace(mask, roiImage);
            
            % in real world coordinates
            mask.global.XYZmm = returnXYZm(mask.global.hdr.mat, mask.global.XYZ);
            
            assert(size(mask.global.XYZmm, 2)==sum(mask.global.img(:)))
            
            LocationsToSample = mask.global.XYZmm;
            
            [~, mask.roi.XYZmm, j] = spm_ROI(xY, LocationsToSample);
            mask.roi.XYZ = mask.global.XYZ(:,j);
            mask.roi.size = size(mask.roi.XYZ, 2);
  
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

function mask = defineGlobalSearchSpace(mask, image)
    
    mask.global.hdr = spm_vol(image);
    mask.global.img = logical(spm_read_vols(mask.global.hdr));
    
    [X, Y, Z] = ind2sub(size(mask.global.img), find(mask.global.img));
    
    % XYZ format
    mask.global.XYZ = [X'; Y'; Z'];
    mask.global.size = size(mask.global.XYZ, 2);
    
end

function XYZmm = returnXYZm(transformationMatrix, XYZ)
    % "voxel to world transformation"
    XYZmm = transformationMatrix(1:3,:) * [XYZ; ones(1, size(XYZ, 2))];
end