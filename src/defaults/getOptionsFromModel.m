function opt = getOptionsFromModel(opt)
  %
  % USAGE::
  %
  %     opt = getOptionsFromModel(opt)
  %
  % (C) Copyright 2022 CPP_SPM developers

  % TODO refactor to pass everything to bids filter file instead of query?

  inputsToOverride = {'task', 'subject', 'space', 'run', 'session', 'acq'};

  bm = BidsModel('file', opt.model.file);
  input = bm.Input;

  fromInput = fieldnames(input);

  inputPresent = ismember(fromInput, inputsToOverride);

  if ~any(inputPresent)
    return

  else

    fromOptions = {'taskName', 'subjects', 'space'};
    fromQuery = {'ses', 'run'};

    optionsPresent = ismember(fromOptions, fieldnames(opt));
    queryPresent = ismember(fromQuery, fieldnames(opt.query));
    optionsPresent = [fromOptions(optionsPresent) fromQuery(queryPresent)];

    optionsToOverride = optionsPresent(ismember(optionsPresent, fromInput(inputPresent)));

    if ~any(isempty(optionsToOverride))
      % TODO check if override is not actually the same value
      % those warnings can be worrying to a new user
      msg = sprintf('\nInput speficied in BIDS model will overide those options:%s\n', ...
                    createUnorderedList(optionsToOverride));
      errorHandling(mfilename(), 'bidsModelOverridesOptions', msg, true, opt.verbosity);
    end

    % TODO refactor to pass everything to bids filter file instead of query?
    for i = 1:numel(fromInput)

      thisInput = fromInput{i};

      switch thisInput

        case 'task'
          opt.taskName = input.task;

        case 'subject'
          opt.subjects = input.subject;

        case 'space'
          opt.space = input.space;

        case  {'run', 'session', 'acq'}
          opt.query.(thisInput) = input.(thisInput);

      end

    end

  end

end
