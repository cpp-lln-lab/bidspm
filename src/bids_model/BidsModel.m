classdef BidsModel < bids.Model
  %
  %

  % (C) Copyright 2022 Remi Gau

  methods

    function obj = BidsModel(varargin)
      obj = obj@bids.Model(varargin{:});
    end

    function [rootNode, rootNodeName] = getRootNode(obj)

      edges = obj.Edges;

      if isempty(edges)
        rootNode = obj.Nodes(1);

      elseif iscell(edges)
        rootNodeName = edges{1}.Source;
        rootNode = obj.get_nodes('Name', rootNodeName);

      elseif isstruct(edges(1))
        rootNodeName = edges(1).Source;
        rootNode = obj.get_nodes('Name', rootNodeName);

      else
        rootNode = obj.Nodes(1);

      end

      if iscell(rootNode)
        rootNode = rootNode{1};
      end

      rootNodeName = rootNode.Name;

    end

    function [transformers, idx] = getBidsTransformers(obj, varargin)

      if isempty(varargin)
        [~, rootNodeName] = obj.getRootNode();
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

    function [model, nodeName] = getDefaultModel(obj, varargin)

      if isempty(varargin)
        [~, nodeName] = obj.getRootNode();
        model = obj.get_model('Name', nodeName);
      else
        [model, idx] = obj.get_model(varargin{:});
        nodes = obj.Nodes;
        if iscell(nodes)
          nodeName = nodes{idx}.Name;
        else
          nodeName = nodes.Name;
        end
      end

    end

    function designMatrix = getBidsDesignMatrix(obj, varargin)

      if isempty(varargin)
        [~, rootNodeName] = obj.getRootNode();
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
                      [returnRtdURL() '#HRF']);
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
          notImplemented(mfilename()(), ...
                         ['HRF model of the type "%s" not yet implemented.\n', ...
                          'Will use SPM canonical HRF insteasd.\n'], ...
                         true);
        otherwise
          notImplemented(mfilename()(), ...
                         ['HRF model of the type "%s" not implemented.\n', ...
                          'Will use SPM canonical HRF insteasd.\n'], ...
                         true);

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
                      [returnRtdURL() '#software']);
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
                      [returnRtdURL() '#software']);

        obj.bidsModelError('noTemporalCorrection', msg);

      end

    end

    function bidsModelError(obj, id, msg)
      msg = sprintf('\n\nFor BIDS stats model named: "%s"\n%s\n', obj.Name, msg);
      errorHandling(mfilename()(), id, msg, obj.tolerant, obj.verbose);
    end

  end
end
