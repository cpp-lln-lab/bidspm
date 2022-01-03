function opt = addStcToQuery(BIDS, opt, subLabel)
  %
  % USAGE::
  %
  %     opt = addStcToQuery(opt, subLabel)
  %
  % In case slice timing correction was performed this update the query to fetch
  % the correct files for realignment.
  %
  % (C) Copyright 2020 CPP_SPM developers

  if ~opt.stc.skip

    filter = opt.query;
    filter.sub =  subLabel;
    filter.suffix = 'bold';
    filter.extension = {'.nii', '.nii.gz'};
    filter.prefix = '';
    % in case task was not passed through opt.query
    if ~isfield(filter, 'task')
      filter.task = opt.taskName;
    end

    sliceOrder = getAndCheckSliceOrder(BIDS, opt, filter);
    if ~isempty(sliceOrder)
      opt.query.desc = 'stc';
    end

  end

end
