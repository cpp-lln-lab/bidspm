function eventSpecification = getEventSpecificationRoiGlm(varargin)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   event_specification = getEventSpecificationRoiGlm(SPM_file, model_file)
  %
  % :param SPM_file: obligatory argument. fullpath to SPM.mat
  % :type SPM_file: path
  % :param model_file: obligatory argument. fullpath to BIDS stats model
  % :type model_file: fullpath
  %
  % :returns: - :event_specification: (structure) (dimension)
  %
  % event_specification(1).name 'F1'
  % event_specification(1).event_spec [1;1]
  % event_specification(1).duration 0
  %
  % Example::
  %
  % (C) Copyright 2022 CPP_SPM developers

  % The code goes below

  p = inputParser;

  isFile = @(x) exist(x, 'file') == 2;

  addRequired(p, 'SPM', isFile);
  addRequired(p, 'modelFile', isFile);

  parse(p, varargin{:});

  SPM = p.Results.SPM;
  modelFile = p.Results.modelFile;

  load(SPM);
  nbRuns = numel(SPM.Sess);

  getModelType(modelFile);
  model = bids.util.jsondecode(modelFile);
  node = returnModelNode(model, 'run');

  eventSpecification = struct('name', '', 'eventSpec', [], 'durations', []);

  if ~isfield(node, 'DummyContrasts')
    return
  end

  if isfield(node.DummyContrasts, 'Contrasts') && ...
      isTtest(node.DummyContrasts)

    % first the contrasts to compute automatically against baseline
    for iCon = 1:length(node.DummyContrasts.Contrasts)

      cdtName = node.DummyContrasts.Contrasts{iCon};
      cdtName = rmTrialTypeStr(cdtName);

      for iRun = 1:nbRuns

        tmp = cat(2, SPM.Sess(iRun).U(:).name);

        conditionPresent = ismember(tmp, cdtName);

        if any(conditionPresent)

          eventSpecification(iCon).name = cdtName;
          eventSpecification(iCon).eventSpec(:, end + 1) = [iRun; find(conditionPresent)];
          eventSpecification(iCon).duration = mean(SPM.Sess(iRun).U(conditionPresent).dur);

        end

      end

    end

  end

end
