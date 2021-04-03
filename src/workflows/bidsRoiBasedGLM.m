% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function bidsRoiBasedGLM(opt)
  %
  %

  funcFWHM = 0;

  [BIDS, opt] = setUpWorkflow(opt, 'roi based glm');

  opt = setStatsDir(opt);
  opt.space = 'individual';
  opt.jobsDir = fullfile(opt.dir.stats, 'JOBS', opt.taskName);

  if isempty(opt.model.file)
    opt = createDefaultModel(BIDS, opt);
  end

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    matlabbatch = [];

    matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel, funcFWHM);

    batchName = ['specify_roi_based_GLM_task-', opt.taskName];

    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    SPM = load(fullfile(getFFXdir(subLabel, funcFWHM, opt), ...
                        'SPM.mat'));

    roiList = spm_select('FPList', ...
                         fullfile(opt.dir.roi, ['sub-' subLabel], 'roi'), ...
                         '^sub-.*_mask.nii$');

    model = mardo(SPM);

    for iROI = 1:size(roiList, 1)

      roiImage = deblank(roiList(iROI, :));

      % create ROI object for Marsbar
      % and convert to matrix format to avoid delicacies of image format
      roiObject = maroi_image(struct( ...
                                     'vol', spm_vol(roiImage), ...
                                     'binarize', true, ...
                                     'func', []));
      roiObject = maroi_matrix(roiObject);

      % Extract data and do MarsBaR estimation
      data = get_marsy(roiObject, model, 'mean');
      estimation = estimate(model, data);

      p = bids.internal.parse_filename(spm_file(roiImage, 'filename'));
      fields = {'hemi', 'desc', 'label'};
      for iField = 1:numel(fields)
        if ~isfield(p, fields{iField})
          p.(fields{iField}) = '';
        end
      end
      nameStructure = struct( ...
                             'sub', subLabel, ...
                             'space', 'individual', ...
                             'hemi', p.hemi, ...
                             'desc', p.desc, ...
                             'label', p.label, ...
                             'type', 'estimates', ...
                             'ext', '.mat');
      newName = createFilename(nameStructure);

      save(fullfile(getFFXdir(subLabel, funcFWHM, opt), newName), ...
           'estimation');

    end

  end

end
