function aliMask = resizeAliMask(opt)
  %
  % USAGE::
  %
  %  aliMask = resizeAliMask(opt)
  %
  %
  % (C) Copyright 2022 CPP_SPM developers
  aliMask = fullfile(spm('dir'), 'toolbox', 'ALI', 'Mask_image', 'mask_controls_vox2mm.nii');

  if opt.toolbox.ALI.unified_segmentation.step1vox ~= 2

    voxdim = repmat(opt.toolbox.ALI.unified_segmentation.step1vox, [3, 1]);
    bb = nan(2, 3);
    ismask = true;
    resize_img(aliMask, voxdim, bb, ismask);

    aliMask = fullfile(spm('dir'), ...
                       'toolbox', ...
                       'ALI', ...
                       'Mask_image', ...
                       ['mask_controls_vox' num2str(voxdim(1)) 'mm.nii']);

    movefile(fullfile(spm('dir'), 'toolbox', 'ALI', 'Mask_image', 'rmask_controls_vox2mm.nii'), ...
             aliMask);
  end

end
