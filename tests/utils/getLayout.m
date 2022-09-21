function BIDS = getLayout(opt)
  %
  % BIDS = getLayout(opt)
  %

  % (C) Copyright 2022 bidspm developers
  try
    load(fullfile(opt.dir.preproc, 'layout.mat'), 'BIDS');
  catch
    BIDS = bids.layout(opt.dir.preproc, 'use_schema', false, 'verbose', opt.verbosity > 0);
    BIDS.raw = bids.layout(opt.dir.raw);
  end
end
