function bidsCreateROI(opt)
  %
  % (C) Copyright 2021 CPP_SPM developers

  if nargin < 1
    opt = [];
  end

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'create ROI');

  opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'cpp_spm-roi'), 'cpath');
  spm_mkdir(fullfile(opt.dir.roi, 'group'));

  opt.dir.jobs = fullfile(opt.dir.roi, 'jobs', opt.taskName);

  hemi = {'L', 'R'};

  for iHemi = 1:numel(hemi)

    for iROI = 1:numel(opt.roi.name)

      extractRoiFromAtlas(fullfile(opt.dir.roi, 'group'), ...
                          opt.roi.atlas, ...
                          opt.roi.name{iROI}, ...
                          hemi{iHemi});

    end

  end

  if any(strcmp(opt.roi.space, 'individual'))

    roiList = spm_select('FPlist', ...
                         fullfile(opt.dir.roi, 'group'), ...
                         '^space-.*_mask.nii$');
    roiList = cellstr(roiList);

    for iSub = 1:numel(opt.subjects)

      subLabel = opt.subjects{iSub};

      printProcessingSubject(iSub, subLabel, opt);

      %% inverse normalize
      deformation_field = bids.query(BIDS, 'data', ...
                                     'sub', subLabel, 'suffix', 'xfm', ...
                                     'to', opt.anatReference.type, 'extension', '.nii');

      assert(~isempty(deformation_field));

      matlabbatch = {};
      for iROI = 1:size(roiList, 1)
        matlabbatch = setBatchNormalize(matlabbatch, ...
                                        deformation_field, ...
                                        nan(1, 3), ...
                                        roiList(iROI, :));
        matlabbatch{end}.spm.spatial.normalise.write.woptions.bb = nan(2, 3);
      end

      saveAndRunWorkflow(matlabbatch, 'inverseNormalize', opt, subLabel);

      %% move and rename file
      spm_mkdir(opt.dir.roi, ['sub-' subLabel], 'roi');

      roiList = spm_select('FPlist', ...
                           fullfile(opt.dir.roi, 'group'), ...
                           '^wspace.*_mask.nii.*$');
      roiList = cellstr(roiList);

      for iROI = 1:size(roiList, 1)

        p = bids.internal.parse_filename(roiList{iROI, 1});

        nameStructure = struct('entities', struct( ...
                                                  'sub', subLabel, ...
                                                  'space', 'individual', ...
                                                  'hemi', p.entities.hemi, ...
                                                  'label', p.entities.label, ...
                                                  'desc', p.entities.desc), ...
                               'suffix', 'mask', ...
                               'ext', '.nii', ...
                               'use_schema', false);
        newName = bids.create_filename(nameStructure);

        movefile(roiList{iROI, 1}, ...
                 fullfile(opt.dir.roi, ['sub-' subLabel], 'roi', newName));

      end

    end
  end

end
