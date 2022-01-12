function matlabbatch = bidsModelSelection(opt)
  %
  % Brief workflow description
  %
  % USAGE::
  %
  %  bidsModelSelection(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % (C) Copyright 2022 CPP_SPM developers

  status = checkToolbox('MACS', 'install', true, 'verbose', opt.verbosity > 0);
  if ~status
    return
  end

  [~, opt] = setUpWorkflow(opt, 'workflow name');

  opt.orderBatches.MACS_model_space = 1;
  opt.orderBatches.MACS_BMS_group_auto = 4;

  names = getMacsModelNames(opt);

  matlabbatch{1}.spm.tools.MACS.MA_model_space.names = names;
  matlabbatch{1}.spm.tools.MACS.MA_model_space.model_files = opt.toolbox.MACS.model.files;
  %   matlabbatch{1}.spm.tools.MACS.MA_model_space.dir = {output_dir};

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    for iModel = 1:size(names, 1)

      %       subj_dir = fullfile(output_dir, [folder_subj{isubj}], 'func');
      %
      %       analysis_dir = fullfile ( ...
      %                                output_dir, ...
      %                                folder_subj{isubj}, 'stats', analysis_dir);
      %
      %       matlabbatch{1}.spm.tools.MACS.MA_model_space.models{1, isubj}{1, iModel} = ...
      %           {fullfile(analysis_dir, 'SPM.mat')};

    end

    matlabbatch{2}.spm.tools.MACS.MA_cvLME_auto.MS_mat(1) = ...
     cfg_dep('MA: define model space: model space (MS.mat file)', ...
             returnDependency(opt, 'MACS_model_space'), ...
             substruct('.', 'MS_mat'));
    matlabbatch{2}.spm.tools.MACS.MA_cvLME_auto.AnC = 0;

    matlabbatch{3}.spm.tools.MACS.MS_PPs_group_auto.MS_mat(1) = ...
     cfg_dep('MA: define model space: model space (MS.mat file)', ...
             returnDependency(opt, 'MACS_model_space'), ...
             substruct('.', 'MS_mat'));
    matlabbatch{3}.spm.tools.MACS.MS_PPs_group_auto.LME_map = 'cvLME';

    matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.MS_mat(1) = ...
     cfg_dep('MA: define model space: model space (MS.mat file)', ...
             returnDependency(opt, 'MACS_model_space'), ...
             substruct('.', 'MS_mat'));
    matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.LME_map = 'cvLME';
    matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.inf_meth = 'RFX-VB';
    matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.EPs = 0;

    matlabbatch{5}.spm.tools.MACS.MS_SMM_BMS.BMS_mat(1) = ...
     cfg_dep('MS: perform BMS (automatic): BMS results (BMS.mat file)', ...
             returnDependency(opt, 'MACS_BMS_group_auto'), ...
             substruct('.', 'BMS_mat'));
    matlabbatch{5}.spm.tools.MACS.MS_SMM_BMS.extent = 10;

    saveAndRunWorkflow(matlabbatch, 'workflow name', opt, subLabel);

  end

end

function names = getMacsModelNames(opt)

  modelFiles = opt.toolbox.MACS.model.files;

  for iModel = 1:numel(modelFiles)
    names{iModel, 1} = getModelName(modelFiles{iModel});
  end

end
