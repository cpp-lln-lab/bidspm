function [BIDS, opt] = getData(varargin)
  %
  % Reads the specified BIDS data set and updates the list of subjects to analyze.
  %
  % USAGE::
  %
  %   [BIDS, opt] = getData(opt, bidsDir, indexDependencies)
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :type  opt:  structure
  %
  % :param bidsDir: the directory where the data is ; defaults to
  %                 ``fullfile(opt.dataDir, '..', 'derivatives', 'bidspm')``
  %
  % :type  bidsDir: char
  %
  % :param indexDependencies: Use ``'index_dependencies', true``
  %                           in bids.layout.
  %
  % :type  indexDependencies: logical
  %
  % :return: opt
  % :rtype: structure
  %
  % :return: BIDS
  % :rtype: structure
  %
  %

  % (C) Copyright 2020 bidspm developers

  isFolder = @(x) isdir(x);

  args = inputParser;

  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'bidsDir', isFolder);
  addOptional(args, 'indexDependencies', true, @islogical);

  try
    parse(args, varargin{:});
  catch ME
    if bids.internal.starts_with(ME.message, 'The value of ')
      msg = sprintf('The following directory does not exist:\n\t%s', ...
                    bids.internal.format_path(varargin{2}));
      id = 'notADirectory';
      logger('ERROR', msg, 'filename', mfilename(), 'id', id);
    else
      rethrow(ME);
    end
  end

  opt = args.Results.opt;
  bidsDir = args.Results.bidsDir;

  indexDependencies = args.Results.indexDependencies;
  if strcmp(opt.pipeline.type, 'stats')
    indexDependencies = false;
  end

  if isfield(opt, 'taskName')
    msg = sprintf('FOR TASK(s): %s', strjoin(opt.taskName, ' '));
    logger('INFO', msg, 'options', opt, 'filename', mfilename());
  end

  validationInputFile(bidsDir, 'dataset_description.json');

  layout_filter = struct([]);
  if ~isempty(opt.subjects{1}) && ~ismember('', opt.subjects)
    layout_filter = struct('sub', {opt.subjects});
  end

  BIDS = bids.layout(bidsDir, ...
                     'use_schema', opt.useBidsSchema, ...
                     'verbose', opt.verbosity > 1, ...
                     'filter', layout_filter, ...
                     'index_dependencies', indexDependencies);

  if strcmp(opt.pipeline.type, 'stats') && ~opt.pipeline.isBms
    if exist(fullfile(opt.dir.raw, 'layout.mat'), 'file') == 2
      msg = sprintf('Loading BIDS raw layout from:\n\t%s', ...
                    bids.internal.format_path(fullfile(opt.dir.raw, 'layout.mat')));
      logger('INFO', msg, 'options', opt, 'filename', mfilename());
      tmp = load(fullfile(opt.dir.raw, 'layout.mat'), 'BIDS');

      if isempty(fieldnames(tmp))
        BIDS.raw = bids.layout(opt.dir.raw, ...
                               'filter', layout_filter, ...
                               'index_dependencies', indexDependencies);
      else
        BIDS.raw = tmp.BIDS;
      end
    else
      BIDS.raw = bids.layout(opt.dir.raw, ...
                             'verbose', opt.verbosity > 1, ...
                             'filter', layout_filter);
    end
  end

  % make sure that the required tasks exist in the data set
  if isfield(opt, 'taskName') && ~any(ismember(opt.taskName, bids.query(BIDS, 'tasks')))

    msg = sprintf(['The task %s that you have asked for ', ...
                   'does not exist in this dataset.\n', ...
                   'List of tasks present in this dataset:\n%s'], ...
                  strjoin(opt.taskName), ...
                  bids.internal.create_unordered_list(bids.query(BIDS, 'tasks')));

    id = 'noMatchingTask';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());

  end

  % TODO add check for space

  % get IDs of all subjects
  opt = getSubjectList(BIDS, opt);

  msg = sprintf('WILL WORK ON SUBJECTS%s', ...
                bids.internal.create_unordered_list(opt.subjects));
  logger('INFO', msg, 'options', opt, 'filename', mfilename());

end
