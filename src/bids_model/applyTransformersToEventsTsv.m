function newContent = applyTransformersToEventsTsv(varargin)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   newContent = applyTransformersToEventsTsv(tsvContent, transformers)
  %
  % :param tsvContent:
  % :type tsvContent: structure
  % :param transformers:
  % :type transformers: structure
  %
  % :returns: - :newContent: (structure)
  %
  % Example::
  %
  % (C) Copyright 2022 CPP_SPM developers

  SUPPORTED_TRANSFORMERS = {'Add', 'Subtract', 'Multiply', 'Divide'};

  p = inputParser;

  default_transformers = 'transformers';

  addRequired(p, 'tsvContent', @isstruct);
  addOptional(p, 'transformers', default_transformers, @isstruct);

  parse(p, varargin{:});

  tsvContent = p.Results.tsvContent;
  transformers = p.Results.transformers;

  if isempty(transformers) || isempty(transformers)
    newContent = struct([]);
    return
  end

  trialTypes = tsvContent.trial_type;
  trialTypesList = unique(trialTypes);

  for iTrans = 1:numel(transformers)

    % TODO make transformers more general
    % - assumes only trial types can be input
    % - assumes a single input and output
    % - assumes transformations are only on onsets
    name = transformers(iTrans).Name;
    value = transformers(iTrans).Value;

    input = transformers(iTrans).Input;
    output = transformers(iTrans).Output;

    for i = 1:numel(input)

      if ismember(name, SUPPORTED_TRANSFORMERS) && ...
          ismember(rmTrialTypeStr(input{i}), trialTypesList)

        idx = find(strcmp(rmTrialTypeStr(input{i}), trialTypes));

        onsets = tsvContent.onset(idx);

        switch lower(name)

          case 'add'
            onsets = onsets + value;

          case 'subtract'
            onsets = onsets - value;

          case 'multiply'
            onsets = onsets * value;

          case 'divide'
            onsets = onsets / value;

          otherwise

            notImplemented(mfilename(), sprintf('Transformer %s not implemented', name), true);

        end

        newContent.(output{i}) = struct('onset', onsets, 'duration', tsvContent.duration(idx));

      end

    end

  end

end
