% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function bidsRFX(action, opt, funcFWHM, conFWHM)
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
  %  bidsRFX(action, [opt,] [funcFWHM = 0,] [conFWHM = 0])
  %
  % :param action: Action to be conducted: ``smoothContrasts`` or ``RFX``
  % :type action: string
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  % :param funcFWHM: How much smoothing was applied to the functional
  %                  data in the preprocessing (Gaussian kernel size).
  % :type funcFWHM: scalar
  % :param conFWHM: How much smoothing will be applied to the contrast
  %                 images (Gaussian kernel size).
  % :type conFWHM: scalar
  %
  % - case ``smoothContrasts``: smooth con images
  % - case ``RFX``: Mean Struct, MeanMask, Factorial design specification and
  %   estimation, Contrast estimation
  %

  if nargin < 2
    opt = [];
  end

  if nargin < 4 || isempty(funcFWHM)
    funcFWHM = 0;
  end

  if nargin < 4 || isempty(conFWHM)
    conFWHM = 0;
  end

  [~, opt] = setUpWorkflow(opt, 'group level GLM');

  switch action

    case 'smoothContrasts'

      matlabbatch = [];
      matlabbatch = setBatchSmoothConImages(matlabbatch, opt, funcFWHM, conFWHM);

      saveAndRunWorkflow(matlabbatch, ...
                         ['smooth_con_FWHM-', num2str(conFWHM), '_task-', opt.taskName], ...
                         opt);

    case 'RFX'

      opt.rfxDir = getRFXdir(opt, funcFWHM, conFWHM);

      % ------
      % TODO
      % - need to rethink where to save the anat and mask
      % - need to smooth the anat
      % - create a masked version of the anat too
      % - needs to be improved (maybe??) as the structural and mask may vary for
      %   different analysis
      % ------
      matlabbatch = [];
      matlabbatch = setBatchMeanAnatAndMask(matlabbatch, ...
                                            opt, ...
                                            funcFWHM, ...
                                            fullfile(opt.derivativesDir, 'group'));
      saveAndRunWorkflow(matlabbatch, 'create_mean_struc_mask', opt);

      % TODO
      % saving needs to be improved (maybe??) as the name may vary with FXHM and contrast
      matlabbatch = [];
      matlabbatch = setBatchFactorialDesign(matlabbatch, opt, funcFWHM, conFWHM);

      % Load the list of contrasts of interest for the RFX
      grpLvlCon = getGrpLevelContrastToCompute(opt);
      matlabbatch = setBatchEstimateModel(matlabbatch, opt, grpLvlCon);

      saveAndRunWorkflow(matlabbatch, 'group_level_model_specification_estimation', opt);

      % TODO
      % saving needs to be improved (maybe??) as the name may vary with FXHM and contrast
      rfxDir = getRFXdir(opt, funcFWHM, conFWHM);
      matlabbatch = [];
      matlabbatch = setBatchGroupLevelContrasts(matlabbatch, grpLvlCon, rfxDir);
      saveAndRunWorkflow(matlabbatch, 'contrasts_rfx', opt);

  end

end
