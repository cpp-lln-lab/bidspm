function bidsRemoveDummies(varargin)
  %
  % Removes dummies from functional files
  %
  % USAGE::
  %
  %  bidsRemoveDummies(opt, 'dummyScans', someInteger, 'force', false)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % :param dummyScans: number of volumes to remove
  % :type dummyScans: integer >= 0
  %
  % :param force: use ``'force', true`` to remove dummy scans even if metadata say
  % they have already been removed
  % :type force: boolean
  %
  % EXAMPLE::
  %
  %     opt.taskName = 'auditory';
  %     opt.dir.input = fullfile(pwd, 'inputs', 'raw');
  %     bidsRemoveDummies(opt, 'dummyScans', 4, 'force', false);
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;

  default_force = false;

  isPositive = @(x) x >= 0;

  addRequired(p, 'opt', @isstruct);
  addParameter(p, 'dummyScans', 0, isPositive);
  addParameter(p, 'force', default_force, @islogical);

  parse(p, varargin{:});

  opt = p.Results.opt;
  dummyScans = p.Results.dummyScans;
  force = p.Results.force;

  if dummyScans == 0
    errorHandling(mfilename(), 'noDummiesToRemove', ...
                  'Number dummy scans to remove set to 0.', true, true);
    return
  end

  if ~isfield(opt, 'taskName') || isempty(opt.taskName)
    errorHandling(mfilename(), 'noTask', 'No task specified.', true, true);
    return
  end

  [BIDS, opt] = setUpWorkflow(opt, 'Removing dummies');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    filter = opt.bidsFilterFile.bold;
    filter.task = opt.taskName;

    files = bids.query(BIDS, 'data', filter);
    metadata = bids.query(BIDS, 'metadata', filter);
    if ~iscell(metadata)
      metadata = {metadata};
    end

    for iFile = 1:size(files, 1)

      printToScreen(sprintf('\n%s\n', files{iFile}), opt);

      removeDummies(files{iFile}, dummyScans, metadata{iFile}, ...
                    'force', force, ...
                    'verbose', opt.verbosity > 0);

    end

  end

end
