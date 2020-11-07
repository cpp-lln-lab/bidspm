% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function sliceOrder = getSliceOrder(opt, verbose)
  %
  % Get the slice order information from the BIDS metadata or from the ``opt``
  % structure.
  %
  % USAGE::
  %
  %  sliceOrder = getSliceOrder(opt, [verbose = false])
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param verbose:
  % :type verbose: boolean
  %
  % :returns: 
  %
  % :sliceOrder: a vector of the time when each slice was acquired in
  % in a volume or indicating the order of acquisition of the slices.
  %
  % In the case the slice timing information was not specified in the json files
  % in the BIDS data set then ``getSliceOrder`` will try to read the ``opt``
  % structure for any relevant information.
  % If this comes out empty then slice timing correction will be skipped.
  %
  % See also: ``bidsSTC``
  %

  if nargin < 2
    verbose = false;
  end

  msg = {};
  wng = {};

  % If slice timing is not in the metadata
  if ~isfield(opt.metadata, 'SliceTiming') || isempty(opt.metadata.SliceTiming)

    msg{end + 1} = ' SLICE TIMING INFORMATION COULD NOT BE EXTRACTED FROM METADATA.\n';
    msg{end + 1} = ' CHECKING IF SPECIFIED IN opt IN THE "opt" STRUCTURE.\n\n';

    % If slice timing information is not in the metadata, you have the option
    % to add the slice order manually in the "opt" in the "getOptions"
    % function
    if ~isempty(opt.sliceOrder)
      sliceOrder = opt.sliceOrder;

      msg{end + 1} = ' SLICE TIMING INFORMATION EXTRACTED FROM OPTIONS.\n\n';

    else

      msg{end + 1} = ' SLICE TIMING INFORMATION COULD NOT BE EXTRACTED.\n';
      wng{end + 1} = 'SKIPPING SLICE TIME CORRECTION: no slice timing specified.\n\n';

      sliceOrder = [];
    end

  else % Otherwise get the slice order from the metadata
    sliceOrder = opt.metadata.SliceTiming;

    msg{end + 1} = ' SLICE TIMING INFORMATION EXTRACTED FROM METADATA.\n\n';

  end

  if verbose
    for iMsg = 1:numel(msg)
      fprintf(1, msg{iMsg});
    end
    for iWng = 1:numel(wng)
      warning(wng{iWng});
    end
  end

end
