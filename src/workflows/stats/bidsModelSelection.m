function matlabbatch = bidsModelSelection(opt)
  %
  % Uses the MACS toolbox to perform model selection.
  %
  % 1. MA_model_space:    defines a model space
  % 2. MA_cvLME_auto:     computes cross-validated log model evidence
  % 3. MS_PPs_group_auto: calculate posterior probabilities from cvLMEs
  % 4. MS_BMS_group_auto: perform cross-validated Bayesian model selection
  % 5. MS_SMM_BMS:        generate selected models maps from BMS
  %
  % USAGE::
  %
  %   bidsModelSelection(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Requirements:
  %
  % - define the list of BIDS stats models in a cell string of fullpaths ::
  %
  %     opt.toolbox.MACS.model.files
  %
  % - all models must have the same ``space`` and ``task`` defined in their inputs
  %
  % - specify each model for each subject::
  %
  %     opt = opt_stats_subject_level();
  %     models = opt.toolbox.MACS.model.files
  %     for i = 1:numel(models)
  %       opt.model.file = models{i};
  %       bidsFFX('specify', opt);
  %     end
  %
  % - for a given subject / model, all runs must have the same numbers of regressors
  %   (so this requires to create dummy regressors in case some subjects are missing
  %   a condition or a confound).
  %
  % For more information see the toolbox manual in the folder
  % ``lib/MACS/MACS_Manual``.
  %
  % Links:
  %
  % - `MACS toolbox repo <https://github.com/JoramSoch/MACS>`_
  %
  % If you use this workflow, please cite the following paper:
  %
  % .. code-block:: bibtex
  %
  %    @article{soch2018jnm,
  %      title={MACS - a new SPM toolbox for model assessment, comparison and selection.},
  %      author={Soch J, Allefeld C},
  %      journal={Journal of Neuroscience Methods},
  %      year={2018},
  %      volume={306},
  %      doi={https://doi.org/10.1016/j.jneumeth.2018.05.017}
  %    }
  %
  % If you use cvBMS or cvBMA, please also cite the respective method:
  %
  % .. code-block:: bibtex
  %
  %    @article{soch2016nimg,
  %      title={How to avoid mismodelling in GLM-based fMRI data analysis:
  %             cross-validated Bayesian model selection.},
  %      author={Soch J, Haynes JD, Allefeld C},
  %      journal={NeuroImage},
  %      year={2016},
  %      volume={141},
  %      doi={https://doi.org/10.1016/j.neuroimage.2016.07.047}
  %    }
  %
  %    @article{soch2017nimg,
  %      title={How to improve parameter estimates in GLM-based fMRI data analysis:
  %             cross-validated Bayesian model averaging.},
  %      author={Soch J, Meyer AP, Haynes JD, Allefeld C},
  %      journal={NeuroImage},
  %      year={2017},
  %      volume={158},
  %      doi={https://doi.org/10.1016/j.neuroimage.2017.06.056}
  %    }
  %
  % (C) Copyright 2022 CPP_SPM developers

  checks(opt);

  workflowName = 'macs model selection';

  [~, opt] = setUpWorkflow(opt, workflowName);

  opt.orderBatches.MACS_model_space = 1;
  opt.orderBatches.MACS_BMS_group_auto = 4;

  opt.dir.output = fullfile(opt.dir.stats, 'derivatives', 'cpp_spm-modelSelection');
  opt.dir.jobs = fullfile(opt.dir.output, 'jobs');

  spm_mkdir(fullfile(opt.dir.output, 'group'));

  initBids(opt, 'description', 'perform model selection', 'force', false);

  names = getMacsModelNames(opt);

  matlabbatch{1}.spm.tools.MACS.MA_model_space.names = names;
  matlabbatch{1}.spm.tools.MACS.MA_model_space.model_files = opt.toolbox.MACS.model.files;
  matlabbatch{1}.spm.tools.MACS.MA_model_space.dir = {fullfile(opt.dir.output, 'group')};

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    for iModel = 1:size(names, 1)

      opt.model.file = opt.toolbox.MACS.model.files{iModel};
      inputs = getBidsModelInput(opt.model.file);
      opt.space = {inputs.space};
      opt.taskName = inputs.task;
      if ~iscell(opt.taskName)
        opt.taskName = {opt.taskName};
      end

      ffxDir = getFFXdir(subLabel, opt);

      spmMatFile = spm_select('FPList', ffxDir, 'SPM.mat');

      if isempty(spmMatFile)
        msg = sprintf('no SPM.mat found in:\n%s\n\n', ffxDir);
        id = 'noSPMmat';
        errorHandling(mfilename(), id, msg, false);
      end

      msg.Subject = subLabel;
      msg.Model = names{iModel};
      msg.Task = opt.taskName;
      msg.Space = opt.space;
      printToScreen(['\n' createUnorderedList(msg) '\n\n' spmMatFile '\n'], opt);

      matlabbatch{1}.spm.tools.MACS.MA_model_space.models{1, iSub}{1, iModel} = {spmMatFile};

      checkAllSessionsHaveSameNbRegressors(spmMatFile);

    end

  end

  matlabbatch{2}.spm.tools.MACS.MA_cvLME_auto.MS_mat(1) = returnDefineModelSpaceDependency(opt);
  matlabbatch{2}.spm.tools.MACS.MA_cvLME_auto.AnC = 0;

  matlabbatch{3}.spm.tools.MACS.MS_PPs_group_auto.MS_mat(1) = returnDefineModelSpaceDependency(opt);
  matlabbatch{3}.spm.tools.MACS.MS_PPs_group_auto.LME_map = 'cvLME';

  matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.MS_mat(1) = returnDefineModelSpaceDependency(opt);
  matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.LME_map = 'cvLME';
  matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.inf_meth = 'RFX-VB';
  matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.EPs = 0;

  matlabbatch{5}.spm.tools.MACS.MS_SMM_BMS.BMS_mat(1) = ...
    cfg_dep('MS: perform BMS (automatic): BMS results (BMS.mat file)', ...
            returnDependency(opt, 'MACS_BMS_group_auto'), ...
            substruct('.', 'BMS_mat'));
  matlabbatch{5}.spm.tools.MACS.MS_SMM_BMS.extent = 10;

  saveAndRunWorkflow(matlabbatch, workflowName, opt);

end

function checks(opt)

  status = checkToolbox('MACS', 'install', true, 'verbose', opt.verbosity > 0);
  if ~status
    id = 'macsToolboxMissing';
    errorHandling(mfilename(), id, '', false);
  end

  if isempty(opt.toolbox.MACS.model.files)
    msg = sprintf('no model list provided in opt.toolbox.MACS.model.files');
    id = 'noModelList';
    errorHandling(mfilename(), id, msg, false);
  end

  % check all models have same space and task inputs
  modelFiles = opt.toolbox.MACS.model.files;

  for iModel = 1:numel(modelFiles)
    if ~(exist(modelFiles{iModel}, 'file') == 2)
      msg = sprintf('This model file does not exist:\n%s\n\n', modelFiles{iModel});
      id = 'noModelFile';
      errorHandling(mfilename(), id, msg, false);
    end
    inputs{iModel, 1} = getBidsModelInput(modelFiles{iModel});
  end

  if any(~cellfun(@(x) isfield(x, 'space'), inputs))
    msg = sprintf('All models must have a space input defined.');
    id = 'missingModelInputSpace';
    errorHandling(mfilename(), id, msg, false);
  end

  if any(~cellfun(@(x) isfield(x, 'task'), inputs))
    msg = sprintf('All models must have a task input defined.');
    id = 'missingModelInputTask';
    errorHandling(mfilename(), id, msg, false);
  end

  space = cellfun(@(x) x.space, inputs, 'UniformOutput', false);
  if numel(unique(space)) > 1
    msg = sprintf('All models must have same space inputs.');
    id = 'differentModelSpace';
    errorHandling(mfilename(), id, msg, false);
  end

  % if some models have more than one task, then class(inputs.task) will be a cell
  % and a char otherwise
  tmp = cellfun(@(x) class(x.task), inputs, 'UniformOutput', false);
  moreThanOneTask = numel(unique(tmp)) > 1;
  if moreThanOneTask
    msg = sprintf('All models must have same task inputs.');
    id = 'differentModelTasks';
    errorHandling(mfilename(), id, msg, false);
  end
  if all(ismember(tmp, 'cell'))
    task = cellfun(@(x) strjoin(x.task, ' '), inputs, 'UniformOutput', false);
  else
    task = cellfun(@(x) x.task, inputs, 'UniformOutput', false);
  end
  if numel(unique(task)) > 1
    msg = sprintf('All models must have same task inputs.');
    id = 'differentModelTasks';
    errorHandling(mfilename(), id, msg, false);
  end

end

function dep = returnDefineModelSpaceDependency(opt)

  dep = cfg_dep('MA: define model space: model space (MS.mat file)', ...
                returnDependency(opt, 'MACS_model_space'), ...
                substruct('.', 'MS_mat'));

end

function names = getMacsModelNames(opt)

  modelFiles = opt.toolbox.MACS.model.files;

  for iModel = 1:numel(modelFiles)
    names{iModel, 1} = getModelName(modelFiles{iModel});
  end

end
