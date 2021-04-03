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

  end

end
