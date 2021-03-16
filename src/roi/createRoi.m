% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function mask = createRoi(type, varargin)
  %
  % Returns a mask to be used as a ROI by ``spm_summarize``.
  % Can also save the ROI as binary image.
  %
  % USAGE::
  %
  %  mask = createROI(type, varargin);
  %
  %  mask = createROI('mask', roiImage, volumeDefiningImage, saveImg = false);
  %  mask = createROI('sphere', sphere, volumeDefiningImage, saveImg = false);
  %  mask = createROI('intersection', roiImage, sphere, volumeDefiningImage, saveImg = false);
  %  mask = createROI('expand', roiImage, sphere, volumeDefiningImage, saveImg = false);
  %
  % See the ``demos/roi`` to see examples on how to use it.
  %
  % :param type: ``'mask'``, ``'sphere'``, ``'intersection'``, ``'expand'``
  % :type type: string
  % :param roiImage: fullpath of the roi image
  % :type roiImage: string
  % :param sphere:
  %                ``sphere.location``: X Y Z coordinates in millimeters
  %                ``sphere.radius``: radius in millimeters
  % :type sphere: structure
  % :param volumeDefiningImage: fullpath of the image that will define the space
  %                             (resolution, ...) if the ROI is to be saved.
  % :type volumeDefiningImage: string
  % :param saveImg: Will save the resulting image as binary mask if set to
  %                 ``true``
  % :type saveImg: boolean
  %
  % :returns:
  %
  %      mask   - structure for the volume of interest adapted from ``spm_ROI``
  %
  %      mask.def           - VOI definition [sphere, mask]
  %      mask.rej           - cell array of disabled VOI definition options
  %      mask.xyz           - centre of VOI {mm} (for sphere)
  %      mask.spec          - VOI definition parameters (radius for sphere)
  %      mask.str           - description of the VOI
  %      mask.roi.size      - number of voxel in ROI
  %      mask.roi.XYZ       - voxel coordinates
  %      mask.roi.XYZmm     - voxel world coordinates
  %      mask.global.hdr    - header of the "search space" where the roi is
  %                           defined
  %      mask.global.img
  %      mask.global.XYZ
  %      mask.global.XYZmm
  %
  %

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
      mask = createRoi('mask', roiImage);

      specification = varargin{2};
      mask2 = createRoi('sphere', specification);

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
        mask = createRoi('intersection', roiImage, specification);
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

  checkDependencies('marsbar');

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
