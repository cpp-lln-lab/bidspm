% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function sliceOrder = getSliceOrder(opt, verbose)
  % get the slice order information from the BIDS data set or from  getOption
  %
  % In the case the slice timing information was not specified in the json FILES
  % in the BIDS data set then it will try to read the opt structure for any relevant information.
  % If this comes out empty then slice timing correction will be skipped.

  if nargin < 2
    verbose = 0;
  end

  msg = {};
  wng = {};

  % IF slice timing is not in the metadata
  if ~isfield(opt.metadata, 'SliceTiming') || isempty(opt.metadata.SliceTiming)

    msg{end + 1} = ' SLICE TIMING INFORMATION COULD NOT BE EXTRACTED FROM METADATA.\n';
    msg{end + 1} = ' CHECKING IF SPECIFIED IN opt IN THE "getOption" FUNCTION.\n\n';

    % IF SLICE TIME information is not in the metadata, you have the option
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
