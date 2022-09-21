function printBatchName(batchName, opt)
  %

  % (C) Copyright 2019 bidspm developers

  msg = sprintf('\n BUILDING JOB: %s\n', lower(batchName));
  printToScreen(msg, opt, 'format', '*blue');

end
