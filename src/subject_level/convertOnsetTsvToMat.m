function fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile)
  %
  % Converts an events.tsv file to an onset file suitable for SPM subject level analysis.
  %
  % The function extracts from the events.tsv file the trials (with type, onsets, and durations)
  % of the conditions of interest as requested in the model.json.
  % It then stores them in the GLM folder in a .mat file
  % that can be fed directly in an SPM GLM batch.
  %
  % USAGE::
  %
  %   fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile)
  %
  % :param opt:
  % :type opt: structure
  % :param tsvFile:
  % :type tsvFile: string
  %
  % :returns: :fullpathOnsetFilename: (string) name of the output ``.mat`` file.
  %
  % See also: createAndReturnOnsetFile
  %
  % (C) Copyright 2019 CPP_SPM developers

  %
  [pth, file, ext] = spm_fileparts(tsvFile);
  tsvFile = validationInputFile(pth, [file, ext]);

  tsvContent = bids.util.tsvread(tsvFile);

  if ~isfield(tsvContent, 'trial_type')

    msg = sprintf('%s\n%s', ...
                  'There was no trial_type field in this file:', ...
                  tsvFile);
    id = 'noTrialType';
    errorHandling(mfilename(), id, msg, false, opt.verbosity);

  end

  % identify the conditions to convolve in the BIDS model
  variablesToConvolve = getVariablesToConvolve(opt.model.file, 'run');

  % create empty cell to be filled in according to the conditions present in each run
  names = {};
  onsets = {};
  durations = {};

  %% EASY: trial types
  isTrialType = strfind(variablesToConvolve, 'trial_type.');
  trialTypes = tsvContent.trial_type;

  % for each condition
  for iCond = 1:numel(isTrialType)

    if isTrialType{iCond}

      conditionName =  rmTrialTypeStr(variablesToConvolve{iCond});

      % Get the index of each condition by comparing the unique names and
      % each line in the tsv files
      idx = find(strcmp(conditionName, trialTypes));

      if ~isempty(idx)
        % Get the onset and duration of each condition
        names{1, end + 1} = conditionName;
        onsets{1, end + 1} = tsvContent.onset(idx)'; %#ok<*AGROW,*NASGU>
        durations{1, end + 1} = tsvContent.duration(idx)';

      else

        msg = sprintf('No trial found for trial type %s in \n %s', conditionName, tsvFile);

        if opt.glm.useDummyRegressor

          names{1, end + 1} = 'dummyRegressor';
          onsets{1, end + 1} = nan;
          durations{1, end + 1} = nan;

          msg = sprintf('No trial found for trial type %s in \n %s\n%s', ...
                        conditionName, ...
                        tsvFile, ...
                        'Adding dummy regressor instead.');

        end

        id = 'noTrialType';
        errorHandling(mfilename(), id, msg, true, opt.verbosity);

      end

    end

  end

  %% MORE COMPLICATED: transformed values
  transformers = getBidsTransformers(opt.model.file);
  transformedConditions = applyTransformersToEventsTsv(tsvContent, transformers);

  for iCond = 1:numel(variablesToConvolve)

    if bids.internal.starts_with(variablesToConvolve{iCond}, 'trial_type.')
      continue
    end

    if ismember(variablesToConvolve{iCond}, fieldnames(transformedConditions))

      names{1, end + 1} = variablesToConvolve{iCond};
      onsets{1, end + 1} = transformedConditions.(variablesToConvolve{iCond}).onset;
      durations{1, end + 1} = transformedConditions.(variablesToConvolve{iCond}).duration;

    else

      msg = sprintf('No transformed variable %s found.', variablesToConvolve{iCond});

      if opt.glm.useDummyRegressor

        names{1, end + 1} = 'dummyRegressor';
        onsets{1, end + 1} = nan;
        durations{1, end + 1} = nan;

        msg = sprintf('No transformed variable %s found. \n%s', ...
                      variablesToConvolve{iCond}, ...
                      'Adding dummy regressor instead.');

      end

      id = 'transformedVariableNotFound';
      errorHandling(mfilename(), id, msg, true, opt.verbosity);

    end

  end

  %% save the onsets as a matfile
  [pth, file] = spm_fileparts(tsvFile);

  p = bids.internal.parse_filename(file);
  p.suffix = 'onsets';
  p.ext = '.mat';

  bidsFile = bids.File(p);

  fullpathOnsetFilename = fullfile(pth, bidsFile.filename);

  save(fullpathOnsetFilename, ...
       'names', 'onsets', 'durations', ...
       '-v7');

end
