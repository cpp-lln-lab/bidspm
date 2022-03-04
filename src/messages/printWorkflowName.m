function printWorkflowName(workflowName, opt)
  %
  % (C) Copyright 2019 CPP_SPM developers

  msg = sprintf('\n\n\nWORKFLOW: %s\n\n', upper(workflowName));

  printToScreen(msg, opt, 'format', '*blue');

end
