function matlabbatch = batch(varargin)
  %
  % Short batch description
  %
  % USAGE::
  %
  %   matlabbatch = setBatchTemplate(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch: matlabbatch to append to.
  % :type matlabbatch: cell
  %
  % :param BIDS: BIDS layout returned by ``getData`` or ``bids.layout`.
  % :type BIDS: structure
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % :param subLabel: subject label
  % :type subLabel: string
  %
  %
  % :returns: - :matlabbatch: (cell) The matlabbatch ready to run the spm job
  %
  %
  % Example::
  %
  %

  % (C) Copyright 2022 bidspm developers

  args = inputParser;

  addRequired(args, 'matlabbatch', @iscell);
  addRequired(args, 'BIDS', @isstruct);
  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'subLabel', @ischar);

  parse(args, varargin{:});

  matlabbatch = args.Results.matlabbatch;
  BIDS = args.Results.BIDS;
  opt = args.Results.opt;
  subLabel = args.Results.subLabel;

  printBatchName('name for this batch', opt);

  for iTask = 1:numel(opt.taskName)

    opt.query.task = opt.taskName{iTask};

    [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

    for iSes = 1:nbSessions

      % get all runs for that subject across all sessions
      [runs, nbRuns] = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

      for iRun = 1:nbRuns

        something = foo();

      end

      runCounter = runCounter + 1;
    end

  end

  matlabbatch{end + 1}.spm.something = something;
  matlabbatch{end}.spm.else = faa;
  matlabbatch{end}.spm.other = fii;

end
