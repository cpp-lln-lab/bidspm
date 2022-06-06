function opt = getOptionsFromModel(opt)
  %
  % USAGE::
  %
  %     opt = getOptionsFromModel(opt)
  %
  % (C) Copyright 2022 CPP_SPM developers

  % TODO refactor to pass everything to bids filter file instead of query?
  % TODO override content in bids_filter_file

  if ~strcmpi(opt.pipeline.type, 'stats')
    return
  end

  if isempty(opt.model.file) || exist(opt.model.file, 'file') ~= 2
    msg = sprintf('model file does not exist:\n %s', opt.model.file);
    errorHandling(mfilename(), 'modelFileMissing', msg, false);
  end

  if ~isfield(opt.model, 'bm') || isempty(opt.model.bm)
    opt.model.bm = BidsModel('file', opt.model.file);
  end

  % any of the func / bold entity
  % from raw or derivatives
  inputsToOverride = {'subject'
                      'session'
                      'task'
                      'acquisition'
                      'ceagent'
                      'reconstruction'
                      'direction'
                      'run'
                      'echo'
                      'part'
                      'space'
                      'description'};

  input = opt.model.bm.Input;

  fromInput = fieldnames(input);

  inputPresent = ismember(fromInput, inputsToOverride);

  if ~any(inputPresent)
    return

  else

    % override with all inputs
    % keep track of status to throw a warning
    % if model.Input actually overrides an option value
    inputsAlreadyInOptions = getInputInOptions(opt);

    % we need the schema to know convert between entity short and long name
    schema = bids.Schema;

    for i = 1:numel(fromInput)

      thisEntity.key = schema.content.objects.entities.(fromInput{i}).entity;
      thisEntity.value = input.(fromInput{i});

      switch thisEntity.key

        case 'task'
          if isfield(opt, 'taskName')
            overrideWarning(opt.taskName, thisEntity, inputsAlreadyInOptions, opt.verbosity);
          end
          opt.taskName = input.task;

        case 'sub'
          if isfield(opt, 'subjects')
            overrideWarning(opt.subjects, thisEntity, inputsAlreadyInOptions, opt.verbosity);
          end
          opt.subjects = input.subject;

        case 'space'
          if isfield(opt, 'space')
            overrideWarning(opt.space, thisEntity, inputsAlreadyInOptions, opt.verbosity);
          end
          opt.space = input.space;

        case  {'ses'
               'acq'
               'ce'
               'rec'
               'dir'
               'run'
               'echo'
               'part'
               'desc'}

          if isfield(opt.query, thisEntity.key)
            overrideWarning(opt.query.(thisEntity.key), ...
                            thisEntity, ...
                            inputsAlreadyInOptions, ...
                            opt.verbosity);
          end

          opt.query.(thisEntity.key) = thisEntity.value;

      end

    end

  end

end

function overrideWarning(thisOption, thisEntity, inputsAlreadyInOptions, verbosity)
  if ~ismember(thisEntity.value, thisOption) && ismember(thisEntity.key, inputsAlreadyInOptions)
    msg = sprintf('\nBIDS stats model Input will overide options:%s\n', ...
                  createUnorderedList(thisEntity));
    errorHandling(mfilename(), 'bidsModelOverridesOptions', msg, true, verbosity);
  end

end

function inputsAlreadyInOptions = getInputInOptions(opt)
  %
  % returns a cellstr of all the BIDS entities that are already present
  % in opt in some way
  %

  fromOptions = {'subjects'
                 'taskName'
                 'space'};

  fromOptionsShortForm = {'sub'
                          'task'
                          'space'};

  fromQuery = {'ses'
               'acq'
               'ce'
               'rec'
               'dir'
               'run'
               'echo'
               'part'
               'desc'};

  inputsAlreadyInOptions = fromOptionsShortForm(ismember(fromOptions, fieldnames(opt)));

  if isfield(opt, 'query')
    queryPresent = ismember(fromQuery, fieldnames(opt.query));
    inputsAlreadyInOptions = [inputsAlreadyInOptions; fromQuery(queryPresent)];
  end

end
