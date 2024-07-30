function matlabbatch = bidsModelSelection(varargin)
  %
  % Uses the MACS toolbox to perform model selection.
  %
  % USAGE::
  %
  %   bidsModelSelection(opt, 'action', 'all')
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  % :type opt: structure
  % :param action: any of ``'all'``, ``'modelSpace'``, ``'cvLME'``,
  %                ``'posterior'``, ``'BMS'``
  % :type action: char
  %
  % Steps are performed in that order:
  %
  % 1. MA_model_space:    defines a model space
  % 2. MA_cvLME_auto:     computes cross-validated log model evidence
  % 3. MS_PPs_group_auto: calculate posterior probabilities from cvLMEs
  % 4. MS_BMS_group_auto: perform cross-validated Bayesian model selection
  % 5. MS_SMM_BMS:        generate selected models maps from BMS
  %
  % - ``'all'``  : performs 1 to 5
  % - ``'modelSpace'``: : performs step 1
  % - ``'cvLME'``: performs steps 1 and 2
  % - ``'posterior'``: performs steps 1 and 3, assuming step 2 has already been run
  % - ``'BMS'``: performs 1, 4 and 5, assuming step 2 and 3 have already been run
  %
  % This way you can run all steps at once::
  %
  % .. code-block:: matlab
  %
  %   bidsModelSelection(opt, 'action', 'all');
  %
  % Or in sequence (can be useful to split running cvLME in several batches of subjects)
  %
  % .. code-block:: matlab
  %
  %   bidsModelSelection(opt, 'action', 'cvLME');
  %   bidsModelSelection(opt, 'action', 'posterior');
  %   bidsModelSelection(opt, 'action', 'BMS');
  %
  % Requirements:
  %
  % - define the list of BIDS stats models in a cell string of fullpaths ::
  %
  %     opt.toolbox.MACS.model.files
  %
  % - all models must have the same ``space`` and ``task`` defined in their inputs
  %
  % - for a given subject / model, all runs must have the same numbers of regressors
  %   This requires to create dummy regressors in case some subjects are missing
  %   a condition or a confound. This can be done by using the `bidsFFX(opt)` with
  %   the option `opt.glm.useDummyRegressor` set to `true`.
  %
  % .. note::
  %
  %    Adding dummy (empty) regressors will make your model non-estimable by
  %    SPM, where as the MACS toolbox can deal with this.
  %
  % - specify each model for each subject
  %
  %   .. code-block:: matlab
  %
  %     opt = opt_stats_subject_level();
  %
  %     opt.glm.useDummyRegressor = true;
  %
  %     models = opt.toolbox.MACS.model.files
  %
  %     for i = 1:numel(models)
  %       opt.model.file = models{i};
  %       bidsFFX('specify', opt);
  %     end
  %
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

  % (C) Copyright 2022 bidspm developers

  allowedActions = @(x) ischar(x) && ismember(lower(x), {'all', ...
                                                         'cvlme', ...
                                                         'modelspace', ...
                                                         'posterior', ...
                                                         'bms'});

  args = inputParser;
  defaultAction = 'all';
  addRequired(args, 'opt', @isstruct);
  addOptional(args, 'action', defaultAction, allowedActions);
  parse(args, varargin{:});

  opt = args.Results.opt;
  action = args.Results.action;

  checks(opt);

  checkHasMacsField = false;
  if ismember(action, {'posterior', 'bms'})
    checkHasMacsField = true;
  end

  workflowName = 'macs model selection';

  [~, opt] = setUpWorkflow(opt, workflowName, opt.dir.raw, true);

  opt.orderBatches.MACS_model_space = 1;
  switch lower(action)
    case 'all'
      opt.orderBatches.MACS_BMS_group_auto = 4;
    case 'bms'
      opt.orderBatches.MACS_BMS_group_auto = 2;
  end

  opt.dir.output = fullfile(opt.dir.stats, 'derivatives', 'bidspm-modelSelection');
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
      opt.model.bm = BidsModel('file', opt.model.file);
      input = opt.model.bm.Input;
      if ischar(input.space)
        opt.space = {input.space};
      elseif iscell(input.space)
        opt.space = input.space;
      end
      opt.taskName = input.task;
      if ~iscell(opt.taskName)
        opt.taskName = {opt.taskName};
      end

      ffxDir = getFFXdir(subLabel, opt);
      if not(checkSpmMat(ffxDir, opt))
        continue
      end
      spmMatFile = spm_select('FPList', ffxDir, 'SPM.mat');

      msg = struct('Subject', subLabel);
      msg.Model = names{iModel};
      msg.Task = opt.taskName;
      msg.Space = opt.space;
      msg = [bids.internal.create_unordered_list(msg), ...
             '\n\n', bids.internal.format_path(spmMatFile), '\n'];
      logger('INFO', msg, 'options', opt, 'filename', mfilename());

      matlabbatch{1}.spm.tools.MACS.MA_model_space.models{1, iSub}{1, iModel} = {spmMatFile};

      load(spmMatFile, 'SPM');
      allRunsHaveSameNbRegressors(SPM);
      checkRegressorName(SPM);

      if checkHasMacsField && ~isfield(SPM, 'MACS')
        errorMsg = sprintf('No cvLME for sub %s model %s. Might lead to an error.', ...
                           subLabel, ...
                           names{iModel});
        id = 'missingMACSField';
        logger('WARNING', errorMsg, 'id', id, 'filename', mfilename(), 'options', opt);
      end

    end

  end

  matlabbatch = seBatchCvLme(matlabbatch, opt, action);

  matlabbatch = seBatchPosteriorProba(matlabbatch, opt, action);

  matlabbatch = seBatchBMS(matlabbatch, opt, action);

  saveAndRunWorkflow(matlabbatch, workflowName, opt);

  cleanUpWorkflow(opt);

end

function matlabbatch = seBatchCvLme(matlabbatch, opt, action)

  if ~ismember(lower(action), {'all', 'cvlme'})
    return
  end

  MA_cvLME_auto.MS_mat(1) = returnDefineModelSpaceDependency(opt);
  MA_cvLME_auto.AnC = 0;

  matlabbatch{end + 1}.spm.tools.MACS.MA_cvLME_auto = MA_cvLME_auto;

end

function matlabbatch = seBatchPosteriorProba(matlabbatch, opt, action)

  if ~ismember(lower(action), {'all', 'posterior'})
    return
  end

  MS_PPs_group_auto.MS_mat(1) = returnDefineModelSpaceDependency(opt);
  MS_PPs_group_auto.LME_map = 'cvLME';

  matlabbatch{end + 1}.spm.tools.MACS.MS_PPs_group_auto = MS_PPs_group_auto;

end

function matlabbatch = seBatchBMS(matlabbatch, opt, action)

  if ~ismember(lower(action), {'all', 'bms'})
    return
  end

  MS_BMS_group_auto.MS_mat(1) = returnDefineModelSpaceDependency(opt);
  MS_BMS_group_auto.LME_map = 'cvLME';
  MS_BMS_group_auto.inf_meth = 'RFX-VB';
  MS_BMS_group_auto.EPs = 0;

  matlabbatch{end + 1}.spm.tools.MACS.MS_BMS_group_auto = MS_BMS_group_auto;

  MS_SMM_BMS.BMS_mat(1) = cfg_dep('MS: perform BMS (automatic): BMS results (BMS.mat file)', ...
                                  returnDependency(opt, 'MACS_BMS_group_auto'), ...
                                  substruct('.', 'BMS_mat'));
  MS_SMM_BMS.extent = 10;

  matlabbatch{end + 1}.spm.tools.MACS.MS_SMM_BMS = MS_SMM_BMS;
end

function checks(opt)

  status = checkToolbox('MACS', 'install', true, 'verbose', opt.verbosity > 0);
  if ~status
    id = 'macsToolboxMissing';
    logger('ERROR', 'MACS toolbox missing', 'id', id, 'filename', mfilename());
  end

  if isempty(opt.toolbox.MACS.model.files)
    msg = sprintf('no model list provided in opt.toolbox.MACS.model.files');
    id = 'noModelList';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end

  % check all models have same space and task inputs
  modelFiles = opt.toolbox.MACS.model.files;

  for iModel = 1:numel(modelFiles)
    if ~(exist(modelFiles{iModel}, 'file') == 2)
      msg = sprintf('This model file does not exist:\n%s\n\n', modelFiles{iModel});
      id = 'noModelFile';
      logger('ERROR', msg, 'id', id, 'filename', mfilename());
    end
    bm = BidsModel('file', modelFiles{iModel});
    inputs{iModel, 1} = bm.Input;
  end

  if any(~cellfun(@(x) isfield(x, 'space'), inputs))
    msg = sprintf('All models must have a space input defined.');
    id = 'missingModelInputSpace';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end

  if any(~cellfun(@(x) isfield(x, 'task'), inputs))
    msg = sprintf('All models must have a task input defined.');
    id = 'missingModelInputTask';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end

  space = cellfun(@(x) x.space, inputs, 'UniformOutput', false);
  if iscell(space)
    space = cellfun(@(x) x.space, inputs);
  end
  if numel(unique(space)) > 1
    msg = sprintf('All models must have same space inputs.');
    id = 'differentModelSpace';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end

  % if some models have more than one task,
  % then class(inputs.task) will be a cell
  % and a char otherwise
  tmp = cellfun(@(x) class(x.task), inputs, 'UniformOutput', false);
  moreThanOneTask = numel(unique(tmp)) > 1;
  if moreThanOneTask
    msg = sprintf('All models must have same task inputs.');
    id = 'differentModelTasks';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end
  if all(ismember(tmp, 'cell'))
    task = cellfun(@(x) strjoin(x.task, ' '), inputs, 'UniformOutput', false);
  else
    task = cellfun(@(x) x.task, inputs, 'UniformOutput', false);
  end
  if numel(unique(task)) > 1
    msg = sprintf('All models must have same task inputs.');
    id = 'differentModelTasks';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
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
    bm = BidsModel('file', modelFiles{iModel});
    names{iModel, 1} = bm.Name;
  end

end
