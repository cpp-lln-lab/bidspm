function repetitionTime = getAndCheckRepetitionTime(varargin)
  %
  % Gets the repetition time for a given bids.query filter (for several files)
  % Throws an error if it returns empty or finds inconsistent repetition times.
  %
  % USAGE::
  %
  %   repetitionTime = getAndCheckRepetitionTime(BIDS, filter)
  %
  % :param BIDS: dataset layout.
  %              See also: bids.layout, getData.
  % :type BIDS: structure
  % :param filter: obligatory argument.
  % :type filter: structure
  %
  % :returns: - :repetitionTime: (float) (1x1)
  %
  % Example::
  %
  %       filter = opt.query;
  %       filter.sub =  subLabel;
  %       filter.suffix = 'bold';
  %       filter.extension = {'.nii', '.nii.gz'};
  %       filter.prefix = '';
  %       filter.task = opt.taskName;
  %
  %       TR = getAndCheckRepetitionTime(BIDS, filter);
  %
  %

  % (C) Copyright 2022 bidspm developers

  args = inputParser;

  addRequired(args, 'BIDS', @isstruct);
  addRequired(args, 'filter', @isstruct);

  parse(args, varargin{:});

  BIDS = args.Results.BIDS;
  filter = args.Results.filter;

  filter.target = 'RepetitionTime';
  repetitionTime = bids.query(BIDS, 'metadata', filter);

  if ~iscell(repetitionTime)
    repetitionTime = {repetitionTime};
  end

  repetitionTime = unique(cat(1, repetitionTime{:}));

  if length(repetitionTime) > 1
    id = 'differentRepetitionTime';
    msg = 'Input files have different repetition time.';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end

  if isempty(repetitionTime)
    msg = sprintf('No repetition time found for filter:\n%s', ...
                  bids.internal.create_unordered_list(filter));
    id = 'noRepetitionTimeFound';
    logger('ERROR', msg, 'filename', mfilename(), 'id', id);
  end

end
