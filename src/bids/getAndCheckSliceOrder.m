function sliceOrder = getAndCheckSliceOrder(BIDS, opt, filter)
  %
  % Get the slice order information from the BIDS metadata.
  % If inconsistent slice timing is found across files
  % it throws an error.
  %
  % USAGE::
  %
  %   sliceOrder = getAndCheckSliceOrder(opt)
  %
  % :param BIDS: dataset layout.
  %              See also: bids.layout, getData.
  % :type  BIDS: structure
  %
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  % :type  opt: structure
  %
  % :returns:
  %   - :sliceOrder: a vector of the time when each slice was acquired in
  %                  in a volume or indicating the order of acquisition of the slices.
  %
  % ``getAndCheckSliceOrder`` will try to read the ``opt`` structure
  % for any relevant information about slice timing.
  % If this is empty, it queries the BIDS dataset to see if there is any
  % consistent slice timing information for a given ``filter``.
  %
  % See also: bidsSTC, setBatchSTC
  %

  % (C) Copyright 2020 bidspm developers

  % TODO support for DelayTime and AcquisitionDuration

  filter.target = 'SliceTiming';
  sliceTiming = bids.query(BIDS, 'metadata', filter);

  if ~iscell(sliceTiming)
    sliceTiming = {sliceTiming};
  end

  if all(cellfun('isempty', sliceTiming))

    sliceOrder = [];

    msg = sprintf('no slice timing found for filter:\n%s.\n\n', ...
                  bids.internal.create_unordered_list(filter));
    id = 'noSliceTimingFound';
    logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);

    return

  end

  sliceTimingLengths = cellfun('length', sliceTiming);
  if length(unique(sliceTimingLengths)) > 1

    sliceOrder = [];

    msg = sprintf(['Inconsistent slice timing found for filter:\n%s.\n\n', ...
                   'Number of slice per volume seems different across bold files.'], ...
                  bids.internal.create_unordered_list(filter));
    id = 'inconsistentSliceTimingLength';
    logger('ERROR', msg, 'id', id, 'filename', mfilename(), 'options', opt);

    return

  end

  % all slice timing should be the same,
  % so we check against the first only
  sliceOrder = sliceTiming{1};

  for i = 1:numel(sliceTiming)

    if sliceTiming{i} ~= sliceOrder

      sliceOrder = [];

      msg = sprintf('Inconsistent slice timing found for filter:\n%s.\n\n', ...
                    bids.internal.create_unordered_list(filter));
      id = 'inconsistentSliceTimingValues';
      logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);

      return
    end

  end

  msg = ' SLICE TIMING INFORMATION EXTRACTED FROM METADATA.';
  logger('INFO', msg, 'options', opt, 'filename', mfilename());

end
