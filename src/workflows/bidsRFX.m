% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

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
  
  [~, opt, group] = setUpWorkflow(opt, 'group level GLM');
  
  switch action
    
    case 'smoothContrasts'
      
      matlabbatch = setBatchSmoothConImages(group, funcFWHM, conFWHM, opt);
      
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
      
      matlabbatch = setBatchMeanAnatAndMask(opt, funcFWHM, rfxDir);
      
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