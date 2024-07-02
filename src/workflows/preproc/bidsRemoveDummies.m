function bidsRemoveDummies(varargin)
  %
  % Removes dummies from functional files
  %
  % USAGE::
  %
  %  bidsRemoveDummies(opt, 'dummyScans', someInteger, 'force', false)
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  % :type opt: structure
  %
  % :param dummyScans: number of volumes to remove
  % :type  dummyScans: integer >= 0
  %
  % :param force: use ``'force', true`` to remove dummy scans even if metadata say
  %               they have already been removed
  % :type  force: logical
  %
  % EXAMPLE::
  %
  %     opt.taskName = 'auditory';
  %     opt.dir.input = fullfile(pwd, 'inputs', 'raw');
  %     bidsRemoveDummies(opt, 'dummyScans', 4, 'force', false);
  %
  %

  % (C) Copyright 2022 bidspm developers

  args = inputParser;

  default_force = false;

  isPositive = @(x) x >= 0;

  addRequired(args, 'opt', @isstruct);
  addParameter(args, 'dummyScans', 0, isPositive);
  addParameter(args, 'force', default_force, @islogical);

  parse(args, varargin{:});

  opt = args.Results.opt;
  dummyScans = args.Results.dummyScans;
  force = args.Results.force;

  if dummyScans == 0
    id = 'noDummiesToRemove';
    msg = 'Number dummy scans to remove set to 0.';
    logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);
    return
  end

  if ~isfield(opt, 'taskName') || isempty(opt.taskName)
    id = 'noTask';
    msg = 'No task specified.';
    logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);
    return
  end

  [BIDS, opt] = setUpWorkflow(opt, 'Removing dummies');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    filter = opt.bidsFilterFile.bold;
    filter.ext = '\.nii.*$';
    filter.prefix = '';
    filter.task = opt.taskName;
    filter.desc = '';
    filter.space = '';
    filter.sub = subLabel;

    files = bids.query(BIDS, 'data', filter);
    metadata = bids.query(BIDS, 'metadata', filter);
    if ~iscell(metadata)
      metadata = {metadata};
    end

    for iFile = 1:size(files, 1)

      printToScreen(sprintf('\n%s\n', bids.internal.format_path(files{iFile})), opt);

      removeDummies(files{iFile}, dummyScans, metadata{iFile}, ...
                    'force', force, ...
                    'verbose', opt.verbosity > 0);

    end

  end

  cleanUpWorkflow(opt);

end
