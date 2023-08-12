function bm = addConfoundsToDesignMatrix(varargin)
  %
  % Add some typical confounds to the design matrix of bids stat model.
  %
  % Similar to the module nilearn.interfaces.fmriprep.load_confounds.
  %
  % USAGE::
  %
  %   bm = addConfoundsToDesignMatrix(bm, 'strategy', strategy);
  %
  %
  % :param bm: bids stats model.
  % :type  bm: :obj:`BidsModel` instance
  %            or path to a ``_smdl.json`` file.
  %
  % :param strategy: structure with the fields:
  %                  ``strategy``,
  %                  ``motion``, ``non_steady_state``, ``scrub``, ``wm_csf``
  % :type  strategy: struct
  %

  % (C) Copyright 2023 bidspm developers

  args = inputParser;
  args.CaseSensitive = false;
  args.KeepUnmatched = false;
  args.FunctionName = 'addConfoundsToDesignMatrix';

  isBidsModelOrFile = @(x) isa(x, 'BidsModel') || exist(x, 'file') == 2;
  addRequired(args, 'bm', isBidsModelOrFile);

  defaultStrategy.strategies = {'motion', 'non_steady_state'};
  addParameter(args, 'strategy', defaultStrategy, @isstruct);

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
        switch strategy.motion
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
        if strategy.non_steady_state
          designMatrix{end + 1} = 'non_steady_state_outlier*';
        end

      case 'scrub'
        if strategy.scrub == 1
          designMatrix{end + 1} = 'motion_outlier*';
        end

      case 'wm_csf'
        switch strategy.wm_csf
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
                       sprintf('Strategey "%s" not implemented.', strategiesToApply{i}));
      otherwise
        logger('WARNING',  sprintf('Unknown strategey: "%s".', ...
                                   strategiesToApply{i}), ...
               'filename', mfilename(), ...
               'id', 'unknownStrategy');
    end
  end

  designMatrix = cleanDesignMatrix(designMatrix);

  bm.Nodes{idx}.Model.X = designMatrix;

end

function designMatrix = cleanDesignMatrix(designMatrix)
  % remove empty and duplicate
  toClean = cellfun(@(x) isempty(x), designMatrix);
  designMatrix(toClean) = [];

  numeric = cellfun(@(x) isnumeric(x), designMatrix);
  tmp = unique(designMatrix(~numeric));
  if size(tmp, 1) > 1
    tmp = tmp';
  end
  if size(designMatrix, 1) > 1
    designMatrix = designMatrix';
  end
  designMatrix = cat(2, tmp, designMatrix(numeric));
end

function strategy = setFieldsStrategy(strategy)

  defaultStrategy.motion = 'basic';
  defaultStrategy.scrub = false;
  defaultStrategy.wm_csf = 'none';
  defaultStrategy.non_steady_state = true;

  strategies = fieldnames(defaultStrategy);
  for i = 1:numel(strategies)
    if ~isfield(strategy, strategies{i})
      strategy.(strategies{i}) = defaultStrategy.(strategies{i});
    end
  end

end
