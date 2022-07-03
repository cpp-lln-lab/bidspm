function sliceOrder = getAndCheckSliceOrder(BIDS, opt, filter)
  %
  % Get the slice order information from the BIDS metadata.
  % If inconsistent slice timing is found across files it returns empty and
  % throws a warning.
  %
  % USAGE::
  %
  %   sliceOrder = getAndCheckSliceOrder(opt)
  %
  % :param BIDS: output of ``getData`` or ``bids.layout``
  % :type BIDS: structure
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param opt: filter for ``bids.query``.
  % :type opt: structure
  %
  % :returns:
  %   - :sliceOrder: a vector of the time when each slice was acquired in
  %                  in a volume or indicating the order of acquisition of the slices.
  %
  % ``getAndCheckSliceOrder`` will try to read the ``opt`` structure for any relevant information
  % about slice timing.
  % If this is empty, it queries the BIDS dataset to ee if there is any
  % consistent slice timing information for a given ``filter``
  %
  % See also: bidsSTC, setBatchSTC
  %
  % (C) Copyright 2020 CPP_SPM developers

  % TODO support for DelayTime and AcquisitionDuration

  if ~isempty(opt.stc.sliceOrder)

    sliceOrder = opt.stc.sliceOrder;

    printToScreen(' SLICE TIMING INFORMATION EXTRACTED FROM OPTIONS.\n\n', opt);

    wng = ['[DEPRECATION WARNING]\n', ...
           'Slice timing in the options will be deprecated in release 3.0.\n', ...
           'Specify it in the relevant JSON file in your BIDS dataset.\n'];
    errorHandling(mfilename(), 'deprecation', wng, true, opt.verbosity);

    return

  end

  filter.target = 'SliceTiming';
  sliceTiming = bids.query(BIDS, 'metadata', filter);

  if ~iscell(sliceTiming)
    sliceTiming = {sliceTiming};
  end

  if all(cellfun('isempty', sliceTiming))

    sliceOrder = [];

    wng = sprintf('no slice timing found for filter:\n%s.\n\n', ...
                  createUnorderedList(filter));
    errorHandling(mfilename(), 'noSliceTimingFound', wng, true, opt.verbosity);

    return

  end

  sliceTimingLengths = cellfun('length', sliceTiming);
  if length(unique(sliceTimingLengths)) > 1

    sliceOrder = [];

    wng = sprintf('inconsistent slice timing found for filter:\n%s.\n\n', ...
                  createUnorderedList(filter));
    errorHandling(mfilename(), 'inconsistentSliceTiming', wng, true, opt.verbosity);

    return

  end

  % all slice timing should be the same,
  % so we check against the first only
  sliceOrder = sliceTiming{1};

  for i = 1:numel(sliceTiming)

    if sliceTiming{i} ~= sliceOrder

      sliceOrder = [];

      wng = sprintf('inconsistent slice timing found for filter:\n%s.\n\n', ...
                    createUnorderedList(filter));
      errorHandling(mfilename(), 'inconsistentSliceTiming', wng, true, opt.verbosity);

      return
    end

  end

  printToScreen(' SLICE TIMING INFORMATION EXTRACTED FROM METADATA.\n', opt);

end
