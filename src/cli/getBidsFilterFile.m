function bidsFilterFile = getBidsFilterFile(args)
  % (C) Copyright 2022 bidspm developers
  if isstruct(args.Results.bids_filter_file)
    bidsFilterFile = args.Results.bids_filter_file;
  else
    bidsFilterFile = bids.util.jsondecode(args.Results.bids_filter_file);
  end

end
