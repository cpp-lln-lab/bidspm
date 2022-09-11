function opt = getOptionsFromModel(opt)
  %
  % USAGE::
  %
  %     opt = getOptionsFromModel(opt)
  %
  % (C) Copyright 2022 bidspm developers

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
  inputsToOverride = {'subject'; ...
                      'session'; ...
                      'task'; ...
                      'acquisition'; ...
                      'ceagent'; ...
                      'reconstruction'; ...
                      'direction'; ...
                      'run'; ...
                      'echo'; ...
                      'part'; ...
                      'space'; ...
                      'description'};

  input = opt.model.bm.Input;

  fromInput = fieldnames(input);

  inputPresent = ismember(fromInput, inputsToOverride);

  if ~any(inputPresent)
    return

  else

    % override with all inputs from model

    % keep track of inputs that already exist in the options to throw a warning
    % if model.Input actually overrides an option value
    inputsAlreadyInOptions = getInputInOptions(opt);

    % we need the schema to know convert between entity short and long name
    schema = bids.Schema;

    for i = 1:numel(fromInput)

      thisEntity.key = schema.content.objects.entities.(fromInput{i}).name;
      thisEntity.value = input.(fromInput{i});

      % 'task', 'sub', 'space' will target a field in options
      % all other entities will target a field in opt.query

      switch thisEntity.key

        case 'task'
          thisEntity.targetField = 'opt.taskName';
          targetField = 'taskName';

        case 'sub'
          thisEntity.targetField = 'opt.subjects';
          targetField = 'subjects';

        case cat(1, fromQuery(), {'space'})
          thisEntity.targetField = ['opt.query.' thisEntity.key];
          targetField = thisEntity.key;

      end

      switch thisEntity.key

        case {'task', 'sub', 'space'}

          if isfield(opt, targetField)
            overrideWarning(opt.(targetField), thisEntity, inputsAlreadyInOptions, opt.verbosity);
          end

          opt.(targetField) = coerceToCellStr(thisEntity.value);

        case fromQuery()

          if isfield(opt.query, targetField)
            overrideWarning(opt.query.(targetField), ...
                            thisEntity, ...
                            inputsAlreadyInOptions, ...
                            opt.verbosity);
          end

          opt.query.(targetField) = thisEntity.value;

      end

    end

  end

end

function a = coerceToCellStr(a)
  % should not be necessary
  % mostly in case users did not validate the inputs
  % that should be array and not strings
  if ischar(a)
    a = cellstr(a);
  end
end

function overrideWarning(thisOption, thisEntity, inputsAlreadyInOptions, verbosity)
  if ischar(thisOption)
    thisOption = {thisOption};
  end
  if ~all(ismember(thisEntity.value, thisOption)) && ...
      ismember(thisEntity.key, inputsAlreadyInOptions)
    msg = sprintf('\nBIDS stats model Input will overide "%s"\n - from  "%s"\n - to "%s"\n', ...
                  thisEntity.targetField, ...
                  strjoin(thisOption, ', '), ...
                  char(thisEntity.value));
    errorHandling(mfilename(), 'modelOverridesOptions', msg, true, verbosity);
  end

end

function inputsAlreadyInOptions = getInputInOptions(opt)
  %
  % returns a cellstr of all the BIDS entities that are already present
  % in opt in some way
  %

  fromOptions = {'subjects'; ...
                 'taskName'; ...
                 'space'};

  fromOptionsShortForm = {'sub'; ...
                          'task'; ...
                          'space'};

  inputsAlreadyInOptions = fromOptionsShortForm(ismember(fromOptions, fieldnames(opt)));

  if isfield(opt, 'query')
    queryPresent = ismember(fromQuery, fieldnames(opt.query));
    inputsAlreadyInOptions = [inputsAlreadyInOptions; fromQuery(queryPresent)];
  end

end

function value = fromQuery(idx)
  value = {'ses'; ...
           'acq'; ...
           'ce'; ...
           'rec'; ...
           'dir'; ...
           'run'; ...
           'echo'; ...
           'part'; ...
           'desc'};
  if nargin > 0
    value = value(idx);
  end
end
