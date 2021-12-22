function printBatchName(batchName, opt)
  %
  % (C) Copyright 2019 CPP_SPM developers

  msg = sprintf('\n BUILDING JOB: %s\n', lower(batchName));
  printToScreen(msg, opt);

end
