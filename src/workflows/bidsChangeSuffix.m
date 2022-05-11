function bidsChangeSuffix(varargin)
  %
  % USAGE::
  %
  %   bidsChangeSuffix(opt, newSuffix, 'filter', struct([]), 'force', false)
  %
  % :param opt: BIDS input dataset must be defined in ``opt.dir.input``;
  %             To test the output, set ``opt.dryRun`` to ``true``.
  % :type opt: structure
  %
  % :param newSuffix: TODO: add checks on newSuffix to make sure it only contains [a-zA-Z0-9]
  % :type newSuffix: string
  %
  % :param filter: structure to decide which files to include. Default:
  % ``struct([])`` for no filter
  % :type filter: structure
  %
  % :param force: If set to ``true`` it will overwrite already existing files. Default: ``false``
  % :type force: boolean
  %
  %
  % EXAMPLE::
  %
  %     opt.dir.input = path_to_dataset;
  %     opt.dryRun = true;
  %
  %     newSuffix = 'vaso';
  %
  %     filter = struct('suffix', 'bold');
  %
  %     bidsChangeSuffix(opt, newSuffix, ...
  %                     'filter', filter, ...
  %                     'force', false)
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;

  addRequired(p, 'opt', @isstruct);
  addRequired(p, 'newSuffix', @ischar);
  addParameter(p, 'filter', struct([]), @isstruct);
  addParameter(p, 'force', false, @islogical);

  parse(p, varargin{:});

  opt = p.Results.opt;
  newSuffix = p.Results.newSuffix;
  filter = p.Results.filter;
  force = p.Results.force;

  [BIDS, opt] = setUpWorkflow(opt, 'changing suffix', opt.dir.input);

  if isempty(filter)
    data = bids.query(BIDS, 'data');
    metadata = bids.query(BIDS, 'metadata');
    metafiles = bids.query(BIDS, 'metafiles');
  else
    data = bids.query(BIDS, 'data', filter);
    metadata = bids.query(BIDS, 'metadata', filter);
    metafiles = bids.query(BIDS, 'metafiles', filter);
  end

  for iFile = 1:size(data, 1)

    specification.suffix = newSuffix;

    bf = bids.File(data{iFile});
    bf = bf.rename('spec', specification, ...
                   'dry_run', opt.dryRun, ...
                   'verbose', opt.verbosity, ...
                   'force', force);

    % createa JSON side car
    if ~opt.dryRun
      json_file = fullfile(fileparts(data{iFile}), bf.json_filename);
      bids.util.jsonencode(json_file, metadata{iFile});
    end

  end

  cleanUpWorkflow(opt);

  % remove old side car JSON files
  if ~opt.dryRun
    for i = 1:numel(metafiles)
      if ischar(metafiles{i})
        metafiles{i} = cellstr(metafiles{i});
      end
      for meta = 1:numel(metafiles{i})
        if exist(metafiles{i}{meta}, 'file')
          printToScreen(sprintf('Deleting %s\n', metafiles{i}{meta}), opt);
          delete(metafiles{i}{meta});
        end
      end
    end
  end

end
