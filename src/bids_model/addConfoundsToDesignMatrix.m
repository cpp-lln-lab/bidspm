function bm = addConfoundsToDesignMatrix(varargin)
  %
  % Add some typical confounds to the design matrix of bids stat model.
  %
  % This will update the design matrix of the root node of the model.
  %
  % Similar to the module
  % https://nilearn.github.io/dev/modules/generated/nilearn.interfaces.fmriprep.load_confounds.html
  %
  % USAGE::
  %
  %   bm = addConfoundsToDesignMatrix(bm, 'strategy', strategy);
  %
  %
  % :param bm: bids stats model.
  % :type  bm: :obj:`BidsModel` instance or path to a ``_smdl.json`` file
  %
  % :type  strategy: struct
  % :param strategy: structure describing the confoudd strategy.
  %
  %                  The structure must have the following field:
  %
  %                  - ``strategy``: cell array of char with the strategies to apply.
  %
  %                  The structure may have the following field:
  %
  %                  - ``motion``: motion regressors strategy
  %                  - ``scrub``: scrubbing strategy
  %                  - ``wm_csf``: white matter and cerebrospinal fluid regressors strategy
  %                  - ``non_steady_state``: non steady state regressors strategy
  %
  %                  See the nilearn documentation (mentioned above)
  %                  for more information on the possible values those strategies can take.
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
  %      bm = addConfoundsToDesignMatrix(path_to_statsmodel_file, 'strategy', strategy);
  %
  %

  % (C) Copyright 2023 bidspm developers

  args = inputParser;
  args.CaseSensitive = false;
  args.KeepUnmatched = false;
  args.FunctionName = 'addConfoundsToDesignMatrix';

  isBidsModelOrFile = @(x) isa(x, 'BidsModel') || exist(x, 'file') == 2;
  addRequired(args, 'bm', isBidsModelOrFile);

  addParameter(args, 'strategy', defaultStrategy(), @isstruct);
  addParameter(args, 'updateName', false, @islogical);

  parse(args, varargin{:});

  bm = args.Results.bm;
  if ischar(bm)
    bm = BidsModel('file', bm);
  end

  strategy = args.Results.strategy;
  strategy = setFieldsStrategy(strategy);

  [~, name] = bm.get_root_node();
  [~, idx] = bm.get_nodes('Name', name);
  designMatrix = bm.get_design_matrix('Name', name);

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

  bm.Nodes{idx}.Model.X = designMatrix;

  if args.Results.updateName
    bm.Nodes{idx}.Name = appendSuffixToNodeName(bm.Nodes{idx}.Name, strategy);
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
