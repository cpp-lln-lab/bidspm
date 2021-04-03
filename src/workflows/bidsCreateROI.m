% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function bidsCreateROI(opt)

  if nargin < 1
    opt = [];
  end

  [BIDS, opt] = setUpWorkflow(opt, 'create ROI');

  opt.roiDir = [opt.derivativesDir '-roi'];
  spm_mkdir(fullfile(opt.roiDir, 'group'));

  hemi = {'lh', 'rh'};

  for iHemi = 1:numel(hemi)

    for iROI = 1:numel(opt.roi.name)

      extractRoiFromAtlas(fullfile(opt.roiDir, 'group'), ...
                          opt.roi.atlas, ...
                          opt.roi.name{iROI}, ...
                          hemi{iHemi});

    end

  end

  if any(strcmp(opt.roi.space, 'individual'))

    roiList = spm_select('FPlist', ...
                         fullfile(opt.roiDir, 'group'), ...
                         '^space-.*_mask.nii$');

    for iSub = 1:numel(opt.subjects)

      subLabel = opt.subjects{iSub};

      printProcessingSubject(iSub, subLabel);

      %% inverse normalize
      [anatImage, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);

      deformation_field = spm_select('FPlist', anatDataDir, ['^iy_' anatImage '$']);

      matlabbatch = {};
      for iROI = 1:size(roiList, 1)
        matlabbatch = setBatchNormalize(matlabbatch, ...
                                        {deformation_field}, ...
                                        nan(1, 3), ...
                                        {roiList(iROI, :)});
        matlabbatch{end}.spm.spatial.normalise.write.woptions.bb = nan(2, 3);
      end

      saveAndRunWorkflow(matlabbatch, 'inverseNormalize', opt, subLabel);

      %% move and rename file
      spm_mkdir(opt.roiDir, ['sub-' subLabel], 'roi');

      roiList = spm_select('FPlist', ...
                           fullfile(opt.roiDir, 'group'), ...
                           '^wspace.*_mask.nii.*$');

      for iROI = 1:size(roiList, 1)

        roiImage = deblank(roiList(iROI, :));

        p = bids.internal.parse_filename(spm_file(roiImage, 'filename'));

        nameStructure = struct( ...
                               'sub', subLabel, ...
                               'space', 'individual', ...
                               'hemi', p.hemi, ...
                               'desc', p.desc, ...
                               'label', p.label, ...
                               'type', 'mask', ...
                               'ext', '.nii');
        newName = createFilename(nameStructure);

        movefile(roiImage, ...
                 fullfile(opt.roiDir, ['sub-' subLabel], 'roi', newName));
      end

    end
  end

end
