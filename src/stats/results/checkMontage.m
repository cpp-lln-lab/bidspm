function [opt, BIDS] = checkMontage(opt, iRes, node, BIDS, subLabel)
  %
  % Check values for create a slice montage.
  %
  % Set default values if they are missing.
  %
  % USAGE::
  %
  %   [opt, BIDS] = checkMontage(opt, iRes, node, BIDS, subLabel)
  %
  %

  % (C) Copyright 2019 bidspm developers

  if nargin < 4
    BIDS = '';
    subLabel = '';
  end

  if isfield(opt.results(iRes), 'montage') && any(opt.results(iRes).montage.do)

    background = opt.results(iRes).montage.background;

    % TODO refactor with getInclusiveMask
    if isstruct(background)

      if ismember(lower(node.Level), {'run', 'session', 'subject'})

        if isempty(BIDS)
          BIDS =  bids.layout(opt.dir.preproc, ...
                              'use_schema', false, ...
                              'index_dependencies', false, ...
                              'filter', struct('sub', {opt.subjects}));
        end

        background.sub = subLabel;
        background.space = opt.space;
        file = bids.query(BIDS, 'data', background);

        if iscell(file)
          if isempty(file)
            % let checkMaskOrUnderlay figure it out
            file = '';

          elseif numel(file) == 1
            file = file{1};

          elseif numel(file) > 1
            file = file{1};

            msg = sprintf('More than 1 overlay image found for %s.\n Taking the first one.', ...
                          bids.internal.create_unordered_list(background));
            id = 'tooManyMontageBackground';
            logger('WARNING', msg, 'id', id, 'options', opt, 'filename', mfilename());
          end

        end

        background = file;

      end

    end

    background = checkMaskOrUnderlay(background, opt, 'background');
    opt.results(iRes).montage.background = background;

  end

end
