function opt = overRideWithBidsModelContent(opt)
  %
  % USAGE::
  %
  %     opt = overRideWithBidsModelContent(opt)
  %
  % (C) Copyright 2022 CPP_SPM developers

  input = getBidsModelInput(opt.model.file);

  inputTypes = fieldnames(input);

  inputPresent = ismember({'task', 'subject', 'space', 'run', 'session'}, inputTypes);

  if ~any(inputPresent)
    return

  else

    optionsPresent = ismember({'taskName', 'subjects', 'space'}, fieldnames(opt));
    queryPresent = ismember({'ses', 'run'}, fieldnames(opt.query));
    optionsPresent = [optionsPresent queryPresent];

    if any(sum([inputPresent; optionsPresent]) > 1)
      msg = 'Input speficied in BIDS model will overide those in the options.';
      errorHandling(mfilename(), 'bidsModelOverridesOptions', msg, true, opt.verbosity);
    end

    if isfield(input, 'task')
      opt.taskName = input.task;
    end
    if isfield(input, 'subject')
      opt.subjects = input.subject;
    end
    if isfield(input, 'space')
      opt.space = input.space;
    end
    if isfield(input, 'run')
      opt.query.run = input.run;
    end
    if isfield(input, 'session')
      opt.query.ses = input.session;
    end

  end

end
