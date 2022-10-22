function [BIDS, opt] = getData(varargin)
  %
  % Reads the specified BIDS data set and updates the list of subjects to analyze.
  %
  % USAGE::
  %
  %   [BIDS, opt] = getData(opt, bidsDir)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %
  % :param bidsDir: the directory where the data is ; default is :
  %                 ``fullfile(opt.dataDir, '..', 'derivatives', 'bidspm')``
  % :type  bidsDir: char
  %
  % :returns:
  %           - :opt: (structure)
  %           - :BIDS: (structure)
  %

  % (C) Copyright 2020 bidspm developers

  isDir = @(x) isdir(x);

  args = inputParser;

  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'bidsDir', isDir);

  try
    parse(args, varargin{:});
  catch ME
    if bids.internal.starts_with(ME.message, 'The value of ')
      msg = sprintf('The following directory does not exist:\n\t%s', varargin{2});
      errorHandling(mfilename(), 'notADirectory', msg, false);
    else
      rethrow(ME);
    end
  end

  opt = args.Results.opt;
  bidsDir = args.Results.bidsDir;

  if isfield(opt, 'taskName')
    msg = sprintf('\nFOR TASK(s): %s\n', strjoin(opt.taskName, ' '));
    printToScreen(msg, opt);
  end

  validationInputFile(bidsDir, 'dataset_description.json');

  BIDS = bids.layout(bidsDir, 'use_schema', opt.useBidsSchema, 'verbose', opt.verbosity > 0);

  if strcmp(opt.pipeline.type, 'stats')
    if exist(fullfile(opt.dir.raw, 'layout.mat'), 'file') == 2
      msg = sprintf('\nLoading BIDS raw layout from:\n\t%s\n', fullfile(opt.dir.raw, 'layout.mat'));
      printToScreen(msg, opt);
      tmp = load(fullfile(opt.dir.raw, 'layout.mat'), 'BIDS');
      if isempty(fieldnames(tmp))
        BIDS.raw = bids.layout(opt.dir.raw);
      else
        BIDS.raw = tmp.BIDS;
      end
    else
      BIDS.raw = bids.layout(opt.dir.raw);
    end
  end

  % make sure that the required tasks exist in the data set
  if isfield(opt, 'taskName') && ~any(ismember(opt.taskName, bids.query(BIDS, 'tasks')))

    msg = sprintf(['The task %s that you have asked for ', ...
                   'does not exist in this data set.\n', ...
                   'List of tasks present in this dataset:\n%s'], ...
                  strjoin(opt.taskName), ...
                  createUnorderedList(bids.query(BIDS, 'tasks')));

    errorHandling(mfilename(), 'noMatchingTask', msg, false);

  end

  % TODO add check for space

  % get IDs of all subjects
  opt = getSubjectList(BIDS, opt);

  printToScreen('\nWILL WORK ON SUBJECTS\n', opt);
  printToScreen(createUnorderedList(opt.subjects), opt);
  printToScreen('\n', opt);

end
