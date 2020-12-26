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

  [~, opt, group] = setUpWorkflow(opt, 'group level GLM');

  matlabbatch = [];

  switch action

    case 'smoothContrasts'

      matlabbatch = setBatchSmoothConImages(matlabbatch, group, funcFWHM, conFWHM, opt);

      saveAndRunWorkflow(matlabbatch, ...
                         ['smooth_con_FWHM-', num2str(conFWHM), '_task-', opt.taskName], ...
                         opt, subID);

    case 'RFX'

      rfxDir = getRFXdir(opt, funcFWHM, conFWHM, contrastName);

      % Load the list of contrasts of interest for the RFX
      grpLvlCon = getGrpLevelContrastToCompute(opt);

      % ------
      % TODO
      % - need to rethink where to save the anat and mask
      % - need to smooth the anat
      % - create a masked version of the anat too
      % - needs to be improved (maybe??) as the structural and mask may vary for
      % different analysis
      % ------

      matlabbatch = setBatchMeanAnatAndMask(matlabbatch, opt, funcFWHM, rfxDir);

      saveAndRunWorkflow(matlabbatch, 'create_mean_struc_mask', opt);

      % ------
      % TODO
      % rfxDir should probably be set in setBatchFactorialDesign
      % needs to be improved (maybe??) as the name may vary with FXHM and
      % contrast
      % ------

      matlabbatch = setBatchFactorialDesign(grpLvlCon, group, conFWHM, rfxDir);

      saveAndRunWorkflow(matlabbatch, 'group_level_specification', opt);

      matlabbatch = setBatchEstimateGroupLevel(grpLvlCon);

      % ------
      % TODO
      % needs to be improved (maybe??) as the name may vary with FXHM and
      % contrast
      % ------

      saveAndRunWorkflow(matlabbatch, 'group_level_model_estimation', opt);

      [matlabbatch] = setBatchContrastsGroupLevel(grpLvlCon, rfxDir);

      % ------
      % TODO
      % needs to be improved (maybe??) as the name may vary with FXHM and
      % contrast
      % ------

      saveAndRunWorkflow(matlabbatch, 'contrasts_rfx', opt);

  end

end

function conName = rmTrialTypeStr(conName)
  conName = strrep(conName, 'trial_type.', '');
end

function matlabbatch = setBatchEstimateGroupLevel(grpLvlCon)

  printBatchName('estimate group level fmri model');

  matlabbatch = {};

  for j = 1:size(grpLvlCon, 1)

    conName = rmTrialTypeStr(grpLvlCon{j});

    matlabbatch{j}.spm.stats.fmri_est.spmmat = ...
      { fullfile(rfxDir, conName, 'SPM.mat') }; %#ok<*AGROW>

    matlabbatch{j}.spm.stats.fmri_est.method.Classical = 1;

  end

end

function [matlabbatch] = setBatchContrastsGroupLevel(grpLvlCon, rfxDir)

  printBatchName('group level contrast estimation');

  matlabbatch = {};

  % ADD/REMOVE CONTRASTS DEPENDING ON YOUR EXPERIMENT AND YOUR GROUPS
  for j = 1:size(grpLvlCon, 1)

    conName = rmTrialTypeStr(grpLvlCon{j});

    matlabbatch{j}.spm.stats.con.spmmat = ...
      {fullfile(rfxDir, conName, 'SPM.mat')};

    matlabbatch{j}.spm.stats.con.consess{1}.tcon.name = 'GROUP';
    matlabbatch{j}.spm.stats.con.consess{1}.tcon.convec = 1;
    matlabbatch{j}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

    matlabbatch{j}.spm.stats.con.delete = 0;
  end

end
