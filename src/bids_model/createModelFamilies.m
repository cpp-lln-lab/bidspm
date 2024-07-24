function createModelFamilies(varargin)
  %
  % Create a family of models from a default one.
  %
  % USAGE::
  %
  %   createModelFamilies(defaultModel, multiverse, outputDir)
  %
  %
  % :param defaultModel: bids stats model that serves as template.
  % :type  defaultModel: :obj:`BidsModel` instance or path to a ``_smdl.json`` file
  %
  % :param multiverse: Structure to describe the multiverse of models.
  %
  %                    Each field of the structure is a dimension of the multiverse.
  %                    Possible dimensions are:
  %
  %                    - ``motion``: motion regressors strategy
  %                    - ``scrub``: scrubbing strategy
  %                    - ``wm_csf``: white matter and cerebrospinal fluid regressors strategy
  %                    - ``non_steady_state``: non steady state regressors strategy
  % :type  multiverse: struct
  %
  % EXAMPLE:
  %
  %  .. code-block:: matlab
  %
  %    multiverse.motion = {'none', 'basic', 'full'};
  %    multiverse.scrub = {false, true};
  %    multiverse.wm_csf = {'none', 'basic', 'full'};
  %    multiverse.non_steady_state = {false, true};
  %
  %    createModelFamilies(path_to_statsmodel_file, multiverse, output_path);
  %
  %

  % (C) Copyright 2023 bidspm developers

  args = inputParser;
  args.CaseSensitive = false;
  args.KeepUnmatched = false;
  args.FunctionName = 'createModelFamilies';

  isBidsModelOrFile = @(x) isa(x, 'BidsModel') || exist(x, 'file') == 2;

  addRequired(args, 'defaultModel', isBidsModelOrFile);
  addRequired(args, 'multiverse', @isstruct);
  addRequired(args, 'outputDir', @isdir);

  parse(args, varargin{:});

  defaultModel = args.Results.defaultModel;
  multiverse = args.Results.multiverse;
  outputDir = args.Results.outputDir;

  if ischar(defaultModel)
    defaultModel = BidsModel('file', defaultModel);
  end

  [~, name] = defaultModel.get_root_node();
  [~, idx] = defaultModel.get_nodes('Name', name);
  defaultModel.Nodes{idx}.Name = '';

  missingDimensionIdx = ~ismember(supportedDimensions(), fieldnames(multiverse));
  missingDimension = supportedDimensions();
  missingDimension = missingDimension(missingDimensionIdx);

  for i = 1:numel(missingDimension)
    multiverse.(missingDimension{i}) = {nan};
  end

  for i = 1:numel(multiverse.motion)
    for j = 1:numel(multiverse.scrub)
      for k = 1:numel(multiverse.wm_csf)
        for l = 1:numel(multiverse.non_steady_state)

          strategy = struct('strategies', {fieldnames(multiverse)}, ...
                            'motion', multiverse.motion{i}, ...
                            'scrub', multiverse.scrub{j}, ...
                            'wm_csf', multiverse.wm_csf{k}, ...
                            'non_steady_state', multiverse.non_steady_state{l});

          bm = defaultModel;
          bm = bm.addConfoundsToDesignMatrix('strategy', strategy, 'updateName', true);

          name = bm.Nodes{idx}.Name;
          bm.Name = name;
          output_file = fullfile(outputDir, ['model_' name '_smdl.json']);

          bm.write(output_file);

        end
      end
    end
  end
end

function value = supportedDimensions()
  value = {'motion', 'non_steady_state',  'wm_csf', 'scrub'};
end
