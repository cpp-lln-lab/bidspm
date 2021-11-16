function bidsRFX(action, opt)
  %
  % - smooths all contrast images created at the subject level
  %
  % OR
  %
  % - creates a mean structural image and mean mask over the sample,
  % - specifies and estimates the group level model,
  % - computes the group level contrasts.
  %
  % USAGE::
  %
  %  bidsRFX(action, opt)
  %
  % :param action: Action to be conducted: ``smoothContrasts`` or ``RFX``
  % :type action: string
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  %  - case ``smoothContrasts``: smooth con images
  %  - case ``RFX``: Mean Struct, MeanMask, Factorial design specification and
  %    estimation, Contrast estimation
  %
  % (C) Copyright 2020 CPP_SPM developers

  [~, opt] = setUpWorkflow(opt, 'group level GLM');

  opt.dir.jobs = fullfile(opt.dir.stats, 'jobs', opt.taskName);

  switch action

    case 'smoothContrasts'

      matlabbatch = {};
      matlabbatch = setBatchSmoothConImages(matlabbatch, opt);

      saveAndRunWorkflow(matlabbatch, ...
                         ['smooth_con_FWHM-', num2str(opt.fwhm.contrast), ...
                          '_task-', opt.taskName], ...
                         opt);

    case 'RFX'

      opt.dir.rfx = getRFXdir(opt);

      % ------
      % TODO
      % - need to rethink where to save the anat and mask
      % - need to smooth the anat
      % - create a masked version of the anat too
      % - needs to be improved (maybe??) as the structural and mask may vary for
      %   different analysis
      % ------
      matlabbatch = {};
      matlabbatch = setBatchMeanAnatAndMask(matlabbatch, ...
                                            opt, ...
                                            fullfile(opt.dir.stats, 'group'));
      saveAndRunWorkflow(matlabbatch, 'create_mean_struc_mask', opt);

      % TODO
      % saving needs to be improved (maybe??) as the name may vary with FXHM and contrast
      matlabbatch = {};
      matlabbatch = setBatchFactorialDesign(matlabbatch, opt);

      % Load the list of contrasts of interest for the RFX
      grpLvlCon = getGrpLevelContrast(opt);
      matlabbatch = setBatchEstimateModel(matlabbatch, opt, grpLvlCon);

      saveAndRunWorkflow(matlabbatch, 'group_level_model_specification_estimation', opt);

      % TODO
      % saving needs to be improved (maybe??) as the name may vary with FwHM and contrast
      rfxDir = getRFXdir(opt);

      matlabbatch = {};
      matlabbatch = setBatchGroupLevelContrasts(matlabbatch, grpLvlCon, rfxDir);
      saveAndRunWorkflow(matlabbatch, 'contrasts_rfx', opt);

  end

end
