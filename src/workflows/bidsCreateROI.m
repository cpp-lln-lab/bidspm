% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function bidsCreateROI(opt)

  if nargin < 1
    opt = [];
  end

  [BIDS, opt, group] = setUpWorkflow(opt, 'create ROI');

  opt.roiDir = [opt.derivativesDir '-roi'];
  mkdir(opt.roiDir);
  mkdir(fullfile(opt.roiDir, 'group'));

  switch opt.roi.atlas

    case 'ProbAtlas_v4'

      [maxProbaFiles, roiLabels] = getRetinoProbaAtlas();

      maxProbaHdr = spm_vol(maxProbaFiles);
      maxProbaVol = spm_read_vols(maxProbaHdr);

  end

  hemi = {'lh', 'rh'};
  for iHemi = 1:numel(hemi)

    for iROI = 1:numel(opt.roi.name)

      roiName = opt.roi.name{iROI};

      roiIdx = ismember(roiLabels.ROI, roiName);

      filename = cat(2, ['group-ROI', ...
                         '_space-MNI', ...
                         '_hemi-', hemi{iHemi}, ...
                         '_desc-', [strrep(opt.roi.atlas, '_', '') roiName], ...
                         '_mask.nii']);

      hdr =  maxProbaHdr(1);

      hdr.fname = fullfile(opt.roiDir, 'group', filename);
      hdr.descrip = ['cpp_spm-roi:' opt.roi.atlas];

      vol = maxProbaVol(:, :, :, iHemi) == roiLabels.label(roiIdx);

      spm_write_vol(hdr, vol);
    end

  end

  if any(strcmp(opt.roi.space, 'individual'))

    %% Loop through the groups, subjects, and sessions
    for iGroup = 1:length(group)

      groupName = group(iGroup).name;

      for iSub = 1:group(iGroup).numSub

        subID = group(iGroup).subNumber{iSub};

        printProcessingSubject(groupName, iSub, subID);

        mkdir(fullfile(opt.roiDir, ['sub-' subID], 'roi'));
        copyfile(fullfile(opt.roiDir, 'group'), ...
                 fullfile(opt.roiDir, ['sub-' subID], 'roi'));

        [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt);

        deformation_field = spm_select('FPlist', anatDataDir, ['^iy_' anatImage '$']);

        roiImg = spm_select('FPlist', ...
                            fullfile(opt.roiDir, ['sub-' subID], 'roi'), ...
                            '^group.*.nii.*$');

        matlabbatch = {};
        for iROI = 1:size(roiImg, 1)
          matlabbatch = setBatchNormalize(matlabbatch, ...
                                          {deformation_field}, ...
                                          nan(1, 3), ...
                                          {roiImg(iROI, :)});
          matlabbatch{end}.spm.spatial.normalise.write.woptions.bb = nan(2, 3);
        end

        saveAndRunWorkflow(matlabbatch, 'inverseNormalize', opt, subID);

        roiImg = spm_select('FPlist', ...
                            fullfile(opt.roiDir, ['sub-' subID], 'roi'), ...
                            '^wgroup.*.nii.*$');

        for iROI = 1:size(roiImg, 1)
          [pth, filename, ext] = spm_fileparts(roiImg(iROI, :));

          filename = strrep(filename, 'wgroup-ROI', ['sub-' subID]);
          filename = strrep(filename, 'space-MNI', 'space-individual');

          copyfile(roiImg(iROI, :), ...
                   fullfile(pth, [filename ext]));
        end

        delete(fullfile(opt.roiDir, ['sub-' subID], 'roi', '*group*.nii'));

      end
    end

  end

end
