% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function bidsRFX(action, funcFWHM, conFWHM, opt)
  %
  % This script smooth all con images created at the fisrt level in each
  % subject, create a mean structural image and mean mask over the
  % population, process the factorial design specification  and estimation
  % and estimate Contrats. ::
  %
  %  bidsRFX(action, funcFWHM, conFWHM, opt)
  %
  % :param action: (string) ``smoothContrasts`` or ``RFX``
  % :param funcFWHM: (scalar)
  % :param conFWHM: (scalar)
  % :param opt: (structure) (see checkOptions())
  %
  %   - case 'smoothContrasts': smooth con images
  %   - case 'RFX': Mean Struct, MeanMask, Factorial design specification and
  %      estimation, Contrast estimation
  %
  %    funcFWHM: How much smoothing was applied to the functional
  %    data in the preprocessing
  %
  %    conFWHM: How much smoothing is required for the CON images for
  %    the second level analysis

  if nargin < 2 || isempty(funcFWHM)
    funcFWHM = 0;
  end

  if nargin < 3 || isempty(conFWHM)
    conFWHM = 0;
  end

  % if input has no opt, load the opt.mat file
  if nargin < 4
    opt = [];
  end
  opt = loadAndCheckOptions(opt);

  % load the subjects/Groups information and the task name
  [group, opt, ~] = getData(opt);

  switch action

    case 'smoothContrasts'

      matlabbatch = setBatchSmoothConImages(group, funcFWHM, conFWHM, opt);

      saveMatlabBatch( ...
                      ['smooth_con_FWHM-', num2str(conFWHM), '_task-', opt.taskName], ...
                      'STC', ...
                      opt);

      spm_jobman('run', matlabbatch);

    case 'RFX'

      fprintf(1, 'Create Mean Struct and Mask IMAGES...');

      rfxDir = getRFXdir(opt, funcFWHM, conFWHM, contrastName);

      % ------
      % TODO
      % - need to rethink where to save the anat and mask
      % - need to smooth the anat
      % - create a masked version of the anat too
      % ------

      matlabbatch = ...
          setBatchMeanAnatAndMask(opt, funcFWHM, rfxDir);

      % ------
      % TODO
      % needs to be improved (maybe??) as the structural and mask may vary for
      % different analysis
      % ------

      saveMatlabBatch(matlabbatch, 'create_mean_struc_mask', opt);

      spm_jobman('run', matlabbatch);

      %% Factorial design specification

      % Load the list of contrasts of interest for the RFX
      grpLvlCon = getGrpLevelContrastToCompute(opt);

      % ------
      % TODO
      % rfxDir should probably be set in setBatchFactorialDesign
      % ------

      rfxDir = getRFXdir(opt, funcFWHM, conFWHM, contrastName);

      matlabbatch = setBatchFactorialDesign(grpLvlCon, group, conFWHM, rfxDir);

      % ------
      % TODO
      % needs to be improved (maybe??) as the name may vary with FXHM and
      % contrast
      % ------

      saveMatlabBatch(matlabbatch, 'rfx_specification', opt);

      fprintf(1, 'Factorial Design Specification...');

      spm_jobman('run', matlabbatch);

      %% Factorial design estimation

      fprintf(1, 'BUILDING JOB: Factorial Design Estimation');

      matlabbatch = {};

      for j = 1:size(grpLvlCon, 1)
        conName = rmTrialTypeStr(grpLvlCon{j});
        matlabbatch{j}.spm.stats.fmri_est.spmmat = ...
            { fullfile(rfxDir, conName, 'SPM.mat') }; %#ok<*AGROW>
        matlabbatch{j}.spm.stats.fmri_est.method.Classical = 1;
      end

      % ------
      % TODO
      % needs to be improved (maybe??) as the name may vary with FXHM and
      % contrast
      % ------

      saveMatlabBatch(matlabbatch, 'rfx_estimation', opt);

      fprintf(1, 'Factorial Design Estimation...');

      spm_jobman('run', matlabbatch);

      %% Contrast estimation

      fprintf(1, 'BUILDING JOB: Contrast estimation');

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

      % ------
      % TODO
      % needs to be improved (maybe??) as the name may vary with FXHM and
      % contrast
      % ------

      saveMatlabBatch(matlabbatch, 'rfx_contrasts', opt);

      fprintf(1, 'Contrast Estimation...');

      spm_jobman('run', matlabbatch);

  end

end

function conName = rmTrialTypeStr(conName)
  conName = strrep(conName, 'trial_type.', '');
end
