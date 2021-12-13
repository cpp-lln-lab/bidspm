function contrasts = specifyContrasts(SPM, taskName, model)
  %
  % Specifies the first level contrasts
  %
  % USAGE::
  %
  %   contrasts = specifyContrasts(SPM, taskName, model)
  %
  % :param SPM: content of SPM.mat
  % :type SPM: structure
  % :param taskName:
  % :type taskName: string
  % :param opt:
  % :type opt: structure
  %
  % :returns: - :contrasts: (type) (dimension)
  %
  % To know the names of the columns of the design matrix, type :
  % ``strvcat(SPM.xX.name)``
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  % TODO refactor code duplication between run level and subject level

  % TODO refactor with some of the functions from the bids-model folder ?

  % TODO what is the expected behavior if a condition is not present ?
  % - create a contrast with the name dummy ?
  % - do not create the contrast ?

  contrasts = struct('C', [], 'name', []);
  counter = 0;

  % for the task of interest
  % The task of interest should probably be captured in the model.json
    %   if ~strcmp(model.Input.task, taskName)
    %     warning('task ''%s'' not listed as input in the model', taskName);
    %     return
    %   end

  % check all the steps specified in the model
  for iStep = 1:length(model.Steps)

    step = model.Steps(iStep);

    if iscell(step)
      step = step{1};
    end

    switch step.Level

      case 'run'

        [contrasts,  counter] = ...
            specifyRunLvlContrasts(contrasts, step, counter, SPM);

      case 'subject'

        [contrasts,  counter] = ...
            specifySubLvlContrasts(contrasts, step, counter, SPM);

    end

  end

end

function  [cdtName, regIdx] = getRegIdx(conList, iCon, SPM, iCdt)
  % get regressors index corresponding to the HRF of of a condition

  if iscell(conList)
    cdtName = conList{iCon};
  elseif isstruct(conList)
    cdtName = conList(iCon).ConditionList{iCdt};
  end

  % get condition name
  cdtName = strrep(cdtName, 'trial_type.', '');

  % get regressors index corresponding to the HRF of that condition
  regIdx = strfind(SPM.xX.name', [' ' cdtName '*bf(1)']);
  regIdx = ~cellfun('isempty', regIdx);  %#ok<*STRCL1>

  checkRegressorFound(regIdx, cdtName);

end

function [contrasts,  counter] = specifySubLvlContrasts(contrasts, step, counter, SPM)

  if isfield(step, 'AutoContrasts')

    % first the contrasts to compute automatically against baseline
    for iCon = 1:length(step.AutoContrasts)

      C = zeros(1, size(SPM.xX.X, 2));

      % get regressors index corresponding to the HRF of that condition
      [cdtName, regIdx] = getRegIdx(step.AutoContrasts, iCon, SPM);

      % give them a value of 1
      C(end, regIdx) = 1;

      % stores the specification
      counter = counter + 1;
      contrasts(counter).C = C; %#ok<*AGROW>
      contrasts(counter).name = cdtName;

      clear regIdx;

    end

  end

  if isfield(step, 'Contrasts')

    % then the contrasts that involve contrasting conditions
    % amongst themselves or something inferior to baseline
    for iCon = 1:length(step.Contrasts)

      C = zeros(1, size(SPM.xX.X, 2));

      for iCdt = 1:length(step.Contrasts(iCon).ConditionList)

        % get regressors index corresponding to the HRF of that condition
        [~, regIdx] = getRegIdx(step.Contrasts, iCon, SPM, iCdt);

        % give them the value specified in the model
        C(end, regIdx) = step.Contrasts(iCon).weights(iCdt);

        clear regIdx;

      end

      % TODO if one of the condition is not found, this contrast should
      % probably not be created ?

      % stores the specification
      counter = counter + 1;
      contrasts(counter).C = C;
      contrasts(counter).name =  step.Contrasts(iCon).Name;

    end

  end

end

function [contrasts,  counter] = specifyRunLvlContrasts(contrasts, step, counter, SPM)

  if isfield(step, 'AutoContrasts')

    % first the contrasts to compute automatically against baseline
    for iCon = 1:length(step.AutoContrasts)

      % get regressors index corresponding to the HRF of that condition
      [cdtName, regIdx] = getRegIdx(step.AutoContrasts, iCon, SPM);

      % For each event of each condition, create a seperate contrast
      regIdx = find(regIdx);
      for iReg = 1:length(regIdx)

        % give each event a value of 1
        C = zeros(1, size(SPM.xX.X, 2));
        C(end, regIdx(iReg)) = 1;

        % stores the specification
        counter = counter + 1;
        contrasts(counter).C = C;
        contrasts(counter).name =  [cdtName, '_', num2str(iReg)];

      end

      clear regIdx;

    end

  end

  if isfield(step, 'Contrasts')

    % then the contrasts that involve contrasting conditions
    % amongst themselves or something inferior to baseline
    for iCon = 1:length(step.Contrasts)

      % get regressors index corresponding to the HRF of that condition
      for iCdt = 1:length(step.Contrasts(iCon).ConditionList)
        [~, regIdx{iCdt}] = getRegIdx(step.Contrasts, iCon, SPM, iCdt);
        regIdx{iCdt} = find(regIdx{iCdt});
      end

      nbRuns = unique(cellfun(@numel, regIdx));

      if length(nbRuns) > 1
        disp(step.Contrasts(iCon).ConditionList);
        warning('Skipping contrast: some runs are missing a condition for the contrast "%s"', ...
                step.Contrasts(iCon).Name);
        continue
      end

      % give them the value specified in the model
      for iRun = 1:nbRuns

        C = zeros(1, size(SPM.xX.X, 2));

        for iCdt = 1:length(step.Contrasts(iCon).ConditionList)
          C(end, regIdx{iCdt}(iRun)) = step.Contrasts(iCon).weights(iCdt);
        end

        % stores the specification
        counter = counter + 1;
        contrasts(counter).C = C;
        contrasts(counter).name = [step.Contrasts(iCon).Name, '_', num2str(iRun)];

      end
      clear regIdx;

    end

  end

end

function checkRegressorFound(regIdx, cdtName)
  regIdx = find(regIdx);
  if all(~regIdx)
    warning('No regressor found for condition "%s"', cdtName);
  end
end
