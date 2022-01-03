function repetitionTime = getAndCheckRepetitionTime(varargin)
  %
  % Gets the repetition time for a given bids.query filter (for several files)
  % Throws an error if it returns empty or finds inconsistent repetition times.
  %
  % USAGE::
  %
  %   repetitionTime = getAndCheckRepetitionTime(BIDS, filter)
  %
  % :param BIDS: obligatory argument.
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
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;

  addRequired(p, 'BIDS', @isstruct);
  addRequired(p, 'filter', @isstruct);

  parse(p, varargin{:});

  BIDS = p.Results.BIDS;
  filter = p.Results.filter;

  filter.target = 'RepetitionTime';
  repetitionTime = bids.query(BIDS, 'metadata', filter);

  if isempty(repetitionTime)
    msg = sprintf('No repetition time found for filter:\n%s', createUnorderedList(filter));
    errorHandling(mfilename(), 'noRepetitionTimeFound', msg, false, true);
  end

  repetitionTime = unique(cat(1, repetitionTime{:}));

  if length(repetitionTime) > 1
    errorHandling(mfilename(), 'differentRepetitionTime', ...
                  'Input files have different repetition time.', ...
                  false, true);
  end

end
