classdef BidsModel < bids.Model
  %
  %

  % (C) Copyright 2022 Remi Gau
  properties

    SPM = [] % content of SPM.mat

  end

  methods

    function obj = set.SPM(obj, SPM)
      SPM = labelSpmSessWithBidsSesAndRun(SPM);
      obj.SPM = SPM;
    end

    function obj = BidsModel(varargin)
      obj = obj@bids.Model(varargin{:});
      obj.SPM = [];
    end

    function [transformers, idx] = getBidsTransformers(obj, varargin)

      if isempty(varargin)
        [~, rootNodeName] = obj.get_root_node();
        [value, idx] = obj.get_transformations('Name', rootNodeName);
      else
        [value, idx] = obj.get_transformations(varargin{:});
      end

      if ~isempty(value)
        % TODO add a check on the transformer type (pybids or not?)
        transformers = value.Instructions;
      else
        transformers = struct([]);
      end

    end

    function nodeName = getNodeName(obj, idx)
      nodes = obj.Nodes;
      if iscell(nodes)
        nodeName = nodes{idx}.Name;
      else
        nodeName = nodes(idx).Name;
      end
    end

    function [model, nodeName] = getDefaultModel(obj, varargin)

      if isempty(varargin)
        [~, nodeName] = obj.get_root_node();
        model = obj.get_model('Name', nodeName);
      else
        [model, iNode] = obj.get_model(varargin{:});
        nodeName = obj.getNodeName(iNode);
      end

    end

    function designMatrix = getBidsDesignMatrix(obj, varargin)

      if isempty(varargin)
        [~, rootNodeName] = obj.get_root_node();
        designMatrix = obj.get_design_matrix('Name', rootNodeName);
      else
        designMatrix = obj.get_design_matrix(varargin{:});
      end

    end

    function modelType = getModelType(obj, varargin)

      [model, nodeName] = obj.getDefaultModel(varargin{:});

      modelType = model.Type;

      if ~strcmpi(modelType, 'glm')
        obj.bidsModelError('notGLM', ...
                           sprintf('model Type is not "glm" for node "%s"', nodeName));
      end

    end

    function HPF = getHighPassFilter(obj, varargin)

      HPF = spm_get_defaults('stats.fmri.hpf');

      [model, nodeName] = obj.getDefaultModel(varargin{:});

      if ~isfield(model, 'Options') || ...
          ~isfield(model.Options, 'HighPassFilterCutoffHz') || ...
          isempty(model.Options.HighPassFilterCutoffHz)

        msg = sprintf(['No high-pass filter for Node "%s"\n', ...
                       'Will use default value instead: %.0f.\n', ...
                       'To silence this warning, set', ...
                       ' the "Model.Options.HighPassFilterCutoffHz"\n', ...
                       'for the "%s" Node in your BIDS stats model.\n', ...
                       'See the documentation for more details:\n\t%s'], ...
                      nodeName, ...
                      spm_get_defaults('stats.fmri.hpf'), ...
                      nodeName, ...
                      returnBsmDocURL('options'));

        opt.verbosity = 0;
        if obj.verbose
          opt.verbosity = 3;
        end
        logger('INFO', msg, 'filename', mfilename(), 'options', opt);

      else

        HPF = 1 / model.Options.HighPassFilterCutoffHz;

      end

    end

    function variablesToConvolve = getVariablesToConvolve(obj, varargin)

      variablesToConvolve = [];

      [model, nodeName] = obj.getDefaultModel(varargin{:});

      if ~isfield(model, 'HRF') || ~isfield(model.HRF, 'Variables')
        obj.bidsModelError('noVariablesToConvolve', ...
                           sprintf('No variables to convolve for node "%s"', nodeName));

      else
        variablesToConvolve = model.HRF.Variables;

      end

    end

    function derivatives = getHRFderivatives(obj, varargin)
      %
      % returns the HRF derivatives of a node of a BIDS statistical model
      %

      HRFderivatives = '';
      derivatives =  [0 0];

      [model, nodeName] = obj.getDefaultModel(varargin{:});

      try
        HRFderivatives = model.HRF.Model;
      catch
        msg = sprintf(['No HRF Model specified for Node "%s".\n', ...
                       'Will use SPM canonical HRF.\n', ...
                       'To silence this warning, set the "Model.HRF.Model"\n', ...
                       'for the "%s" Node in your BIDS stats model.\n', ...
                       'See the documentation for more details:\n\t%s'], ...
                      nodeName, ...
                      nodeName, ...
                      returnRtdURL('', 'HRF'));

        opt.verbosity = 0;
        if obj.verbose
          opt.verbosity = 1;
        end
        logger('INFO', msg, 'filename', mfilename(), 'options', opt);
      end

      HRFderivatives = lower(strrep(HRFderivatives, ' ', ''));

      switch HRFderivatives
        case 'spm'
          derivatives =  [0 0];
        case 'spm+derivative'
          derivatives =  [1 0];
        case 'spm+derivative+dispersion'
          derivatives =  [1 1];
        case 'fir'
          notImplemented(mfilename(), ...
                         ['HRF model of the type "%s" not yet implemented.\n', ...
                          'Will use SPM canonical HRF insteasd.\n']);
        otherwise
          notImplemented(mfilename(), ...
                         ['HRF model of the type "%s" not implemented.\n', ...
                          'Will use SPM canonical HRF insteasd.\n']);

      end

    end

    function [mask, nodeName] = getModelMask(obj, varargin)
      %
      % returns the mask of a node of a BIDS statistical model
      %

      mask =  '';

      [model, nodeName] = obj.getDefaultModel(varargin{:});

      try
        mask = model.Options.Mask;
      catch
        msg = sprintf(['No Mask for Node "%s".\n', ...
                       'To silence this warning, set the Mask', ...
                       ' "Model.Options.Mask"\n', ...
                       'for the "%s" Node in your BIDS stats model.\n', ...
                       'See the documentation for more details:\n\t%s'], ...
                      nodeName, ...
                      nodeName, ...
                      returnBsmDocURL('options'));

        opt.verbosity = 0;
        if obj.verbose
          opt.verbosity = 1;
        end
        logger('INFO', msg, 'filename', mfilename(), 'options', opt);

      end

    end

    function parametricModulations = getParametricModulations(obj, varargin)
      [model, ~] = obj.getDefaultModel(varargin{:});
      parametricModulations = {};
      if isfield(model, 'Software') && ...
          isfield(model.Software, 'SPM') && ...
            isfield(model.Software.SPM, 'ParametricModulations')

        parametricModulations = model.Software.SPM.ParametricModulations;
      end
    end

    function threshold = getInclusiveMaskThreshold(obj, varargin)
      %
      % returns the threshold for inclusive masking of subject level GLM
      % node of a BIDS statistical model
      %

      threshold =  spm_get_defaults('mask.thresh');

      [model, nodeName] = obj.getDefaultModel(varargin{:});

      if isfield(model, 'Software') && ...
           isfield(model.Software, 'SPM') && ...
             isfield(model.Software.SPM, 'InclusiveMaskingThreshold')

        threshold = model.Software.SPM.InclusiveMaskingThreshold;

      else

        msg = sprintf(['No inclusive mask threshold for Node "%s".\n', ...
                       'Will use default value instead: %.2f.', ...
                       '\nTo silence this warning,', ...
                       ' set the "Model.Software.SPM.InclusiveMaskingThreshold"\n', ...
                       'for the "%s" Node in your BIDS stats model.\n', ...
                       'See the documentation for more details:\n\t%s'], ...
                      nodeName, ...
                      spm_get_defaults('mask.thresh'), ...
                      nodeName, ...
                      returnRtdURL('', 'software'));

        opt.verbosity = 0;
        if obj.verbose
          opt.verbosity = 1;
        end
        logger('INFO', msg, 'filename', mfilename(), 'options', opt);

      end

      if strcmpi(threshold, '-Inf')

        threshold =  -Inf;

      end

    end

    function autoCorCorrection = getSerialCorrelationCorrection(obj, varargin)
      %
      % returns the Serial Correlation Correction of a node of a BIDS statistical model
      %

      autoCorCorrection =  spm_get_defaults('stats.fmri.cvi');

      [model, nodeName] = obj.getDefaultModel(varargin{:});

      if isfield(model, 'Software') && ...
          isfield(model.Software, 'SPM') && ...
          isfield(model.Software.SPM, 'SerialCorrelation')
        autoCorCorrection = model.Software.SPM.SerialCorrelation;

      else

        msg = sprintf(['No temporal correlation correction for Node "%s".\n', ...
                       'Will use default value instead: "%s".', ...
                       '\nTo silence this warning,', ...
                       ' set the "Model.Software.SPM.SerialCorrelation"\n', ...
                       'for the "%s" Node in your BIDS stats model.\n', ...
                       'See the documentation for more details:\n\t%s'], ...
                      nodeName, ...
                      spm_get_defaults('stats.fmri.cvi'), ...
                      nodeName, ...
                      returnRtdURL('', 'software'));

        opt.verbosity = 0;
        if obj.verbose
          opt.verbosity = 1;
        end
        logger('INFO', msg, 'filename', mfilename(), 'options', opt);

      end

    end

    function results = getResults(obj)
      %    return results from all nodes

      results = struct([]);
      idx = 1;

      Nodes = obj.get_nodes();

      for iNode = 1:numel(Nodes)

        nodeName = obj.getNodeName(iNode);
        model = obj.get_model('Name', nodeName);

        if isfield(model, 'Software') && ...
            isfield(model.Software, 'bidspm') && ...
            isfield(model.Software.bidspm, 'Results')

          resultsForNode = model.Software.bidspm.Results;
          for i = 1:numel(resultsForNode)

            thisResult = resultsForNode(i);
            thisResult = fillInResultStructure(thisResult);
            thisResult.nodeName = nodeName;
            if idx == 1
              results = thisResult;
            else
              results(idx) = thisResult;
            end

            idx = idx + 1;
          end
        end

      end

    end

    function [type, groupBy] = groupLevelGlmType(obj, nodeName, participants)
      %
      % Return type of GLM for a dataset level node.
      %
      % USAGE::
      %
      %  [type, groupBy] = bm.groupLevelGlmType(obj, nodeName, participants)
      %
      % :param nodeName:
      % :type  nodeName: char
      %
      % :param participants: content of participants.tsv
      % :type  participants: struct
      %
      if nargin < 3
        participants = struct();
      end

      node = obj.get_nodes('Name', nodeName);

      groupBy = node.GroupBy;
      type = 'unknown';

      if ~strcmpi(node.Level, 'Dataset')
        return
      end

      designMatrix = node.Model.X;

      if isnumeric(designMatrix) && designMatrix == 1
        type = 'one_sample_t_test';

      elseif iscell(designMatrix) && numel(designMatrix) == 2

        groupColumHdr = getGroupColumnHdrFromDesignMatrix(obj, nodeName);

        if isempty(groupColumHdr) || ~isfield(participants, groupColumHdr)
          type = 'unknown';
        else
          levels = participants.(groupColumHdr);
          switch numel(unique(levels))
            case 1
              type = 'one_sample_t_test';
            case 2
              type = 'two_sample_t_test';
            otherwise
              type = 'one_way_anova';
          end
        end

      end

    end

    function groupColumnHdr = getGroupColumnHdrFromDesignMatrix(obj, nodeName)
      node = obj.get_nodes('Name', nodeName);
      designMatrix = node.Model.X;
      if iscell(designMatrix) && numel(designMatrix) == 2
        designMatrix = removeIntercept(designMatrix);
        groupColumnHdr = designMatrix{1};
      else
        groupColumnHdr = '';
      end
    end

    function groupColumnHdr = getGroupColumnHdrFromGroupBy(obj, nodeName, participants)
      node = obj.get_nodes('Name', nodeName);
      groupBy = node.GroupBy;
      groupColumnHdr = intersect(groupBy, fieldnames(participants));
      if isempty(groupColumnHdr)
        groupColumnHdr = '';
      else
        groupColumnHdr = groupColumnHdr{1};
      end
    end

    function obj = addConfoundsToDesignMatrix(obj, varargin)
      %
      % Add some typical confounds to the design matrix of bids stat model.
      %
      % This will update the design matrix of the root node of the model.
      %
      % Similar to the :func:`nilearn.interfaces.fmriprep.load_confounds`
      %
      % USAGE::
      %
      %   bm = bm.addConfoundsToDesignMatrix('strategy', strategy);
      %
      %
      % :param bm: bids stats model.
      % :type  bm: :obj:`BidsModel` instance or path
      %            to a ``_smdl.json`` file
      %
      % :type  strategy: struct
      % :param strategy: structure describing the confoudd strategy.
      %
      %                  The structure must have the following field:
      %
      %                  - ``strategy``: cell array of char
      %                    with the strategies to apply.
      %
      %                  The structure may have the following field:
      %
      %                  - ``motion``: motion regressors strategy
      %                  - ``scrub``: scrubbing strategy
      %                  - ``wm_csf``: white matter
      %                    and cerebrospinal fluid regressors strategy
      %                  - ``non_steady_state``:
      %                    non steady state regressors strategy
      %
      %                  See the nilearn documentation (mentioned above)
      %                  for more information on the possible values
      %                  those strategies can take.
      %
      % :type  updateName: logical
      % :param updateName: Append the name of the root node
      %                    with a string describing the counfounds added.
      %
      %                    ``rp-{motion}_scrub-{scrub}_tissue-{wm_csf}_nsso-{non_steady_state}``
      %
      %                    default = ``false``
      %
      %
      % :rtype: :obj:`BidsModel` instance
      % :return: bids stats model with the confounds added.
      %
      % EXAMPLE:
      %
      %  .. code-block:: matlab
      %
      %
      %      strategy.strategies = {'motion', 'wm_csf', 'scrub', 'non_steady_state'};
      %      strategy.motion = 'full';
      %      strategy.scrub = true;
      %      strategy.non_steady_state = true;
      %
      %      bm = bm.addConfoundsToDesignMatrix('strategy', strategy);
      %
      %

      % (C) Copyright 2023 bidspm developers

      args = inputParser;
      args.CaseSensitive = false;
      args.KeepUnmatched = false;
      args.FunctionName = 'addConfoundsToDesignMatrix';

      addParameter(args, 'strategy', defaultStrategy(), @isstruct);
      addParameter(args, 'updateName', false, @islogical);

      parse(args, varargin{:});

      strategy = args.Results.strategy;
      strategy = setFieldsStrategy(strategy);

      [~, name] = obj.get_root_node();
      [~, idx] = obj.get_nodes('Name', name);
      designMatrix = obj.get_design_matrix('Name', name);

      strategiesToApply = strategy.strategies;
      for i = 1:numel(strategiesToApply)

        switch strategiesToApply{i}

          case 'motion'
            switch strategy.motion{1}
              case 'none'
              case 'basic'
                designMatrix{end + 1} = 'rot_?'; %#ok<*AGROW>
                designMatrix{end + 1} = 'trans_?';
              case {'power2', 'derivatives' }
                notImplemented(mfilename(), ...
                               sprintf('motion "%s" not implemented.', strategy.motion));
              case 'full'
                designMatrix{end + 1} = 'rot_*';
                designMatrix{end + 1} = 'trans_*';
            end

          case 'non_steady_state'
            if strategy.non_steady_state{1}
              designMatrix{end + 1} = 'non_steady_state_outlier*';
            end

          case 'scrub'
            if strategy.scrub{1}
              designMatrix{end + 1} = 'motion_outlier*';
            end

          case 'wm_csf'
            switch strategy.wm_csf{1}
              case 'none'
              case 'basic'
                designMatrix{end + 1} = 'csf';
                designMatrix{end + 1} = 'white';
              case 'full'
                designMatrix{end + 1} = 'csf_*';
                designMatrix{end + 1} = 'white_*';
              otherwise
                notImplemented(mfilename(), ...
                               sprintf('wm_csf "%s" not implemented.', strategiesToApply{i}));
            end

          case {'global_signal', 'compcorstr', 'n_compcorstr'}
            notImplemented(mfilename(), ...
                           sprintf(['Strategey "%s" not implemented.\n', ...
                                    'Supported strategies are:%s'], ...
                                   strategiesToApply{i}, ...
                                   bids.internal.create_unordered_list(supportedStrategies())));
          otherwise
            logger('WARNING',  sprintf('Unknown strategey: "%s".', ...
                                       strategiesToApply{i}), ...
                   'filename', mfilename(), ...
                   'id', 'unknownStrategy');
        end
      end

      designMatrix = cleanDesignMatrix(designMatrix);

      obj.Nodes{idx}.Model.X = designMatrix;

      if args.Results.updateName
        obj.Nodes{idx}.Name = appendSuffixToNodeName(obj.Nodes{idx}.Name, strategy);
      end

    end

    function validateRootNode(obj)
      thisNode = obj.get_root_node();

      if ismember(lower(thisNode.Level), {'session', 'subject'})

        notImplemented(mfilename(), ...
                       '"session" and "subject" level Node not implemented yet');

      elseif ismember(lower(thisNode.Level), {'dataset'})

        msg = sprintf(['Your model seems to be having dataset Node at its root\n.', ...
                       'Validate it: ', ...
                       'https://bids-standard.github.io/stats-models/validator.html\n']);
        obj.tolerant = false;
        id = 'wrongLevel';
        bidsModelError(obj, id, msg);

      end
    end

    function status = validateGroupBy(obj, nodeName, participants)
      %
      % USAGE::
      %
      %   bm = bm.validateGroupBy(nodeName, participants);
      %
      % Only certain type of GroupBy supported for now for each level
      %
      % This helps doing some defensive programming.
      %

      % (C) Copyright 2022 bidspm developers

      status = false;

      node = obj.get_nodes('Name', nodeName);
      if isempty(node)
        return
      end

      groupBy = sort(node.GroupBy);

      if nargin < 3
        participants = struct();
      end

      extraVar = fieldnames(participants);

      switch lower(node.Level)

        case 'run'

          % only certain type of GroupBy supported for now
          supportedGroupBy = {'["run", "subject"]', '["run", "session", "subject"]'};
          if ismember('run', groupBy) && ...
              all(ismember(groupBy, {'run', 'session', 'subject'}))
            status = true;
          end

        case 'session'

          % only certain type of GroupBy supported for now
          supportedGroupBy = {'["contrast", "session", "subject"]'};
          if numel(groupBy) == 3 && ...
              all(ismember(groupBy, {'contrast', 'session', 'subject'}))
            status = true;
          end

        case 'subject'

          supportedGroupBy = {'["contrast", "subject"]'};
          if numel(groupBy) == 2 && ...
              all(ismember(groupBy, {'contrast', 'subject'}))
            status = true;
          end

        case 'dataset'

          % only certain type of GroupBy supported for now
          supportedGroupBy = {'["contrast"]', ...
                              '["contrast", "x"] for "x" being a participant.tsv column name.'};

          if numel(groupBy) == 1 && ismember(lower(groupBy), {'contrast'})
            status = true;
          elseif numel(groupBy) == 2 && any(ismember(lower(groupBy), {'contrast'})) && ...
            iscellstr(extraVar) && numel(extraVar) > 0 && any(ismember(groupBy, extraVar))
            status = true;
          end

      end

      if status
        return
      end

      template = 'only "GroupBy": %s supported %s node level';
      msg = sprintf(template, ...
                    bids.internal.create_unordered_list(supportedGroupBy), ...
                    node.Level);
      notImplemented(mfilename(), msg);
    end

    function validateConstrasts(obj)
      % validate all contrasts spec in the model

      Nodes = obj.get_nodes();

      for iNode = 1:numel(Nodes)

        node = obj.get_nodes('Name', obj.getNodeName(iNode));

        if isfield(node, 'Contrasts')
          for iContrast = 1:numel(node.Contrasts)
            conditionList = node.Contrasts{iContrast}.ConditionList;
            contrast = ['Contrast ' node.Contrasts{iContrast}.Name];
            obj.validateConditionNames(conditionList, node.Name, contrast);
          end
        end

        if isfield(node, 'DummyContrasts')
          if isfield(node.DummyContrasts, 'Contrasts')
            Contrasts = node.DummyContrasts.Contrasts;

          else
            if strcmpi(node.Level, 'run')
              Contrasts = node.Model.HRF.Variables;
            else
              Contrasts = node.Model.X;
              if ~iscell(Contrasts)
                Contrasts = {Contrasts};
              end
              % no need to validate intercept
              isIntercept = cellfun(@(x) x == 1, Contrasts);
              Contrasts(isIntercept) = [];
            end
          end
          obj.validateConditionNames(Contrasts, node.Name, 'DummyConstrasts');
        end

      end

    end

    function validateConditionNames(obj, conditionList, nodeName, contrast)
      anchor = 'statistics-how-should-i-name-my-conditions-in-my-events-tsv';
      baseMsg = ['This may lead to an error during results computation.\n', ...
                 'Consider changing the name of your conditions.\n', ...
                 'See the FAQ: ' returnRtdURL('FAQ', anchor)];

      problematicConditions = {};
      for iCondition = 1:numel(conditionList)
        if  ~isempty(regexp(conditionList{iCondition}, '^.*_[0-9]*$', 'match'))
          problematicConditions{end + 1} = conditionList{iCondition}; %#ok<*AGROW>
        end
      end
      if ~isempty(problematicConditions)
        msg = sprintf([contrast ' of Node %s ', ...
                       'contains conditions ending with _[0-9]*: ''%s''.\n', ...
                       baseMsg], ...
                      nodeName, ...
                      bids.internal.create_unordered_list(problematicConditions));
        obj.tolerant = true;
        obj.bidsModelError('invalidConditionName', msg);
      end
    end

    function bidsModelError(obj, id, msg)
      msg = sprintf('\nFor BIDS stats model named: "%s"\n%s', obj.Name, msg);
      opt.verbosity = 0;
      if obj.verbose
        opt.verbosity = 1;
      end
      if obj.tolerant
        logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);
      else
        logger('ERROR', msg, 'id', id, 'filename', mfilename());
      end
    end

  end
end

function name = appendSuffixToNodeName(name, strategy)
  if ~isempty(name)
    name = [name, '_'];
  end
  suffix =  sprintf('rp-%s_scrub-%i_tissue-%s_nsso-%i', ...
                    strategy.motion{1}, ...
                    strategy.scrub{1}, ...
                    strategy.wm_csf{1}, ...
                    strategy.non_steady_state{1});

  name = [name suffix];
end

function value = supportedStrategies()
  value = {'motion', 'non_steady_state',  'wm_csf', 'scrub'};
end

function  value = defaultStrategy()
  value.strategies = {};
  value.motion = 'none';
  value.scrub = false;
  value.wm_csf = 'none';
  value.non_steady_state = false;
end

function designMatrix = cleanDesignMatrix(designMatrix)
  % remove empty and duplicate
  toClean = cellfun(@(x) isempty(x), designMatrix);
  designMatrix(toClean) = [];

  if isempty(designMatrix)
    return
  end
  if size(designMatrix, 1) > 1
    designMatrix = designMatrix';
  end

  numeric = cellfun(@(x) isnumeric(x), designMatrix);
  tmp = unique(designMatrix(~numeric));

  designMatrix = cat(2, tmp, designMatrix(numeric));
end

function strategy = setFieldsStrategy(strategy)

  tmp = defaultStrategy();

  strategies = fieldnames(defaultStrategy());
  for i = 1:numel(strategies)

    if ~isfield(strategy, strategies{i})
      strategy.(strategies{i}) = tmp.(strategies{i});
    end

    if ~iscell(strategy.(strategies{i}))
      strategy.(strategies{i}) = {strategy.(strategies{i})};
    end

    if ~isempty(strategy.(strategies{i})) && ...
        isnumeric(strategy.(strategies{i}){1}) && ...
        isnan(strategy.(strategies{i}){1})
      strategy.(strategies{i}){1} = tmp.(strategies{i});
    end

  end

end

function designMatrix = removeIntercept(designMatrix)
  %
  % remove intercept because SPM includes it anyway
  %

  isIntercept = cellfun(@(x) (numel(x) == 1) && (x == 1), designMatrix, 'UniformOutput', true);
  designMatrix(isIntercept) = [];
end
