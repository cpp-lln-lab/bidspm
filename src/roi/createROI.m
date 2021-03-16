function mask = createROI(type, varargin)
  %

  %   mask = createROI('mask', roiName, dataImage, opt.save.roi);
  %   mask = createROI('sphere', sphere, dataImage, opt.save.roi);
  %   mask = createROI('intersection', roiName, sphere, dataImage, opt.save.roi);
  %   mask = createROI('expand', roiName, sphere, dataImage, opt.save.roi);

  %
  % type: 'mask', 'sphere', 'intersection', 'expand'
  % roiImage:
  %           - fullpath of the roi image
  %           - structure with:
  %               sphere.location = location; % X Y Z coordinates in millimeters
  %               sphere.radius = radius; % radius in millimeters

  %      mask     - VOI structure
  %      mask.def      - VOI definition [sphere, box, mask, cluster, all]
  %      mask.rej      - cell array of disabled VOI definition options
  %      mask.xyz      - centre of VOI {mm}
  %      mask.spec     - VOI definition parameters
  %      mask.str      - description of the VOI
  %      mask.roi.size
  %      mask.roi.XYZ
  %      mask.roi.XYZmm
  %      mask.global.hdr
  %      mask.global.img
  %      mask.global.XYZ
  %      mask.global.XYZmm

  if islogical(varargin{end})
    saveImg = varargin{end};
  else
    saveImg = false;
  end

  if saveImg
    switch type
      case {'sphere', 'mask'}
        volumeDefiningImage = varargin{2};
      case {'intersection', 'expand'}
        volumeDefiningImage = varargin{3};
    end
  end

  switch type

    case 'sphere'

      specification = varargin{1};

      mask.def = type;
      mask.spec = specification.radius;
      mask.xyz = specification.location;

      if size(mask.xyz, 1) ~= 3
        mask.xyz = mask.xyz';
      end

      mask = spm_ROI(mask);
      mask.roi.XYZmm = [];

    case 'mask'

      roiImage = varargin{1};

      mask = struct('XYZmm', []);
      mask = defineGlobalSearchSpace(mask, roiImage);

      % in real world coordinates
      mask.global.XYZmm = returnXYZm(mask.global.hdr.mat, mask.global.XYZ);

      assert(size(mask.global.XYZmm, 2) == sum(mask.global.img(:)));

      locationsToSample = mask.global.XYZmm;

      mask.def = type;
      mask.spec = roiImage;
      [~, mask.roi.XYZmm, j] = spm_ROI(mask, locationsToSample);

      mask.roi.XYZ = mask.global.XYZ(:, j);

      mask = setRoiSizeAndType(mask, type);

    case 'intersection'

      roiImage = varargin{1};
      mask = createROI('mask', roiImage);

      specification = varargin{2};
      mask2 = createROI('sphere', specification);

      locationsToSample = mask.global.XYZmm;

      [~, mask.roi.XYZmm] = spm_ROI(mask2, locationsToSample);

      mask = setRoiSizeAndType(mask, type);

    case 'expand'

      roiImage = varargin{1};
      specification = varargin{2};

      % take as radius step the smallest voxel dimension of the roi image
      hdr = spm_vol(roiImage);
      dim = diag(hdr.mat);
      radiusStep = min(abs(dim(1:3)));

      while  true
        mask = createROI('intersection', roiImage, specification);
        mask.roi.radius = specification.radius;
        if mask.roi.size > specification.maxNbVoxels
          break
        end
        specification.radius = specification.radius + radiusStep;
      end

      mask = setRoiSizeAndType(mask, type);

  end

  if saveImg
    saveRoi(mask, volumeDefiningImage);
  end

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
  XYZmm = transformationMatrix(1:3, :) * [XYZ; ones(1, size(XYZ, 2))];
end

function saveRoi(mask, volumeDefiningImage)

  switch mask.def

    case 'sphere'

      [~, mask.roi.XYZmm] = spm_ROI(mask, volumeDefiningImage);
      mask = setRoiSizeAndType(mask, mask.def);

      radius = mask.spec;
      center = mask.xyz;

      descrip = sprintf('%0.1fmm radius sphere at [%0.1f %0.1f %0.1f]', radius, center);
      label = sprintf('sphere_%0.0f-%0.0f_%0.0f_%0.0f', radius, center);

    otherwise

      label = [mask.def '-roiMcRoiFace'];
      descrip = [mask.def '-roiMcRoiFace'];

  end

  % use the marsbar toolbox
  roiObject = maroi_pointlist(struct('XYZ', mask.roi.XYZmm, ...
                                     'mat', spm_get_space(volumeDefiningImage), ...
                                     'label', label, ...
                                     'descrip', descrip));

  roiName = sprintf('%s.nii', label);
  save_as_image(roiObject, fullfile(pwd, roiName));

end

function mask = setRoiSizeAndType(mask, type)
  mask.def = type;
  mask.roi.size = size(mask.roi.XYZmm, 2);
end
