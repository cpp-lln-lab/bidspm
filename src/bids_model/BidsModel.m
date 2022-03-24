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

      % TODO deal with case where edges is a struct
      %
      % if isstruct(edges)
      %   rootNodeName = edges(1).Source;
      % else iscell(edges)
      %   rootNodeName = edges{1}.Source
      % end
      if isstruct(edges{1})
        rootNodeName = edges{1}.Source;
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
        nodeName = nodes{idx}.Name;
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
                           sprintf('model Type is not ''glm'' for node ''%s''', nodeName));
      end

    end

    function HPF = getHighPassFilter(obj, varargin)

      HPF = spm_get_defaults('stats.fmri.hpf');

      [model, nodeName] = obj.getDefaultModel(varargin{:});

      if ~isfield(model.Options, 'HighPassFilterCutoffHz') || ...
          isempty(model.Options.HighPassFilterCutoffHz)

        obj.bidsModelError('noHighPassFilter', ...
                           sprintf('No high-pass filter for node ''%s''', nodeName));

      else

        HPF = 1 / model.Options.HighPassFilterCutoffHz;

      end

    end

    function variablesToConvolve = getVariablesToConvolve(obj, varargin)

      variablesToConvolve = [];

      [model, nodeName] = obj.getDefaultModel(varargin{:});

      if ~isfield(model, 'HRF') || ~isfield(model.HRF, 'Variables')
        obj.bidsModelError('noVariablesToConvolve', ...
                           sprintf('No variables to convolve for node ''%s''', nodeName));

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
        HRFderivatives = model.Software.SPM.HRFderivatives;
      catch
        obj.bidsModelError('noHRFderivatives', ...
                           sprintf('No HRF derivatives for node ''%s''', nodeName));
      end

      if isempty(HRFderivatives) || strcmpi(HRFderivatives, 'none')
        return
      elseif strcmpi(HRFderivatives, 'temporal')
        derivatives =  [1 0];
      else
        derivatives =  [1 1];
      end

    end

    function mask = getModelMask(obj, varargin)
      %
      % returns the mask of a node of a BIDS statistical model
      %

      mask =  '';

      [model, nodeName] = obj.getDefaultModel(varargin{:});

      try
        mask = model.Options.Mask;
      catch
        obj.bidsModelError('noMask', sprintf('No mask for Node ''%s''', nodeName));
      end

    end

    function threshold = getInclusiveMaskThreshold(obj, varargin)
      %
      % returns the threshold for inclusive masking of subject level GLM
      % node of a BIDS statistical model
      %

      threshold =  spm_get_defaults('mask.thresh');

      [model, nodeName] = obj.getDefaultModel(varargin{:});

      if isfield(model.Software, 'SPM') && isfield(model.Software.SPM, 'InclusiveMaskingThreshold')

        threshold = model.Software.SPM.InclusiveMaskingThreshold;

      else

        obj.bidsModelError('noInclMaskThresh', ...
                           sprintf('No inclusive mask threshold for Node ''%s''', nodeName));

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

      if isfield(model.Software, 'SPM') && isfield(model.Software.SPM, 'SerialCorrelation')
        autoCorCorrection = model.Software.SPM.SerialCorrelation;

      else
        obj.bidsModelError('noTemporalCorrection', ...
                           sprintf('No temporal correlation correction for Node ''%s''', nodeName));
      end

    end

    function bidsModelError(obj, id, msg)
      msg = sprintf('%s in BIDS model ''%s''', msg, obj.Name);
      errorHandling(mfilename(), id, msg, obj.tolerant, obj.verbose);
    end

  end
end
