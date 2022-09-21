function printWorkflowName(workflowName, opt)
  %

  % (C) Copyright 2019 bidspm developers

  msg = sprintf('\n\n\nWORKFLOW: %s\n\n', upper(workflowName));

  printToScreen(msg, opt, 'format', '*blue');

end
