function printWorkflowName(workflowName, opt)
  %

  % (C) Copyright 2019 bidspm developers

  msg = sprintf('WORKFLOW: %s', upper(workflowName));
  logger('INFO', msg, 'options', opt, 'filename', mfilename());

end
