classdef BidsModel < bids.Model
  %
  %

  % (C) Copyright 2022 Remi Gau

  methods

    function obj = BidsModel(varargin)
      obj = obj@bids.Model(varargin{:});
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

      if ~isfield(model.Options, 'HighPassFilterCutoffHz') || ...
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
        obj.bidsModelError('noHighPassFilter', msg);

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
        obj.bidsModelError('noHRFderivatives', msg);
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
        obj.bidsModelError('noMask', msg);

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
        obj.bidsModelError('noInclMaskThresh', msg);

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

        obj.bidsModelError('noTemporalCorrection', msg);

      end

    end

    function results = getResults(obj)

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

        if isfield(node, 'DummyContrasts') && ...
             isfield(node.DummyContrasts, 'Contrasts')
          Contrasts = node.DummyContrasts.Contrasts;
          obj.validateConditionNames(Contrasts, node.Name, 'DummyConstrasts');
        end

      end

    end

    function validateConditionNames(obj, conditionList, nodeName, contrast)
      anchor = 'statistics-how-should-i-name-my-conditions-in-my-events-tsv';
      baseMsg = ['This will lead to an error during results computation.\n', ...
                 'Change the name of your conditions.\n', ...
                 'See the FAQ: ' returnRtdURL('FAQ', anchor)];

      for iCondition = 1:numel(conditionList)
        if  ~isempty(regexp(conditionList{iCondition}, '^.*_[0-9]*$', 'match'))
          msg = sprintf([contrast ' of Node %s ', ...
                         'contains conditions ending with _[0-9]*: ''%s''.\n', ...
                         baseMsg], ...
                        nodeName, ...
                        conditionList{iCondition});
          obj.tolerant = false;
          obj.bidsModelError('invalidConditionName', msg);
        end
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
