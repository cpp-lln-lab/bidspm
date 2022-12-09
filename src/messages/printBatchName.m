function printBatchName(batchName, opt)
  %

  % (C) Copyright 2019 bidspm developers

  msg = sprintf(' BUILDING JOB: %s', lower(batchName));
  logger('INFO', msg, opt, mfilename);

end
