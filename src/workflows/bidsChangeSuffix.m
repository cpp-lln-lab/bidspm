function bidsChangeSuffix(varargin)
  %
  % USAGE::
  %
  %   bidsChangeSuffix(opt, newSuffix, 'filter', struct([]), 'force', false)
  %
  % :param opt: Options chosen for the analysis. To test the output, set ``opt.dryRun`` to ``true``.
  %             See :func:`checkOptions`.
  % :type  opt: structure
  %
  % :param newSuffix:
  % :type  newSuffix: char
  %
  % :param filter: structure to decide which files to include. Default:
  %                ``struct([])`` for no filter
  % :type  filter: structure
  %
  % :param force: If set to ``true`` it will overwrite already existing files. Default: ``false``
  % :type  force: logical
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

  % (C) Copyright 2022 bidspm developers

  % TODO: add checks on newSuffix to make sure it only contains [a-zA-Z0-9]

  args = inputParser;

  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'newSuffix', @ischar);
  addParameter(args, 'filter', struct([]), @isstruct);
  addParameter(args, 'force', false, @islogical);

  parse(args, varargin{:});

  opt = args.Results.opt;
  newSuffix = args.Results.newSuffix;
  filter = args.Results.filter;
  force = args.Results.force;

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

  if isstruct(metadata) && isempty(fieldnames(metadata))
    warning('No metadata for filter: %s', ...
            bids.internal.create_unordered_list(filter));
  end

  if isstruct(metadata)
    tmp = {metadata};
    metadata = tmp;
  end

  for iFile = 1:size(data, 1)

    specification.suffix = newSuffix;

    bf = bids.File(data{iFile});
    bf = bf.rename('spec', specification, ...
                   'dry_run', opt.dryRun, ...
                   'verbose', opt.verbosity, ...
                   'force', force);

    % create JSON side car
    if ~opt.dryRun && ~isempty(fieldnames(metadata{iFile}))
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
