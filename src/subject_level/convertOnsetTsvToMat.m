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

  variablesToConvolve = getVariablesToConvolve(opt.model.file, 'run');

  designMatrx = getBidsDesignMatrix(opt.model.file, 'run');

  % create empty cell to be filled in according to the conditions present in each run
  names = {};
  onsets = {};
  durations = {};

  transformers = getBidsTransformers(opt.model.file);
  tsvContent = applyTransformersToEventsTsv(tsvContent, transformers);

  for iCond = 1:numel(variablesToConvolve)

    trialTypeNotFound = false;
    variableNotFound = false;
    extra = '';

    % first assume the input is from events.tsv
    tokens = regexp(variablesToConvolve{iCond}, '\.', 'split');

    if ismember(tokens{1}, fieldnames(tsvContent))

      trialTypes = tsvContent.(tokens{1});
      conditionName = strjoin(tokens(2:end), '.');

      idx = find(strcmp(conditionName, trialTypes));

      if ~isempty(idx)

        if ~ismember(variablesToConvolve{iCond}, designMatrx)
          continue
        end

        names{1, end + 1} = conditionName;
        onsets{1, end + 1} = tsvContent.onset(idx)'; %#ok<*AGROW,*NASGU>
        durations{1, end + 1} = tsvContent.duration(idx)';

      else

        trialTypeNotFound = true;
        errorID = 'trialTypeNotFound';
        input1 = 'Trial type';

      end

    else

      variableNotFound = true;
      errorID = 'variableNotFound';
      input1 = 'Variable';

    end

    if variableNotFound || trialTypeNotFound

      if opt.glm.useDummyRegressor
        [names, onsets, durations] = addDummyRegressor(names, onsets, durations);
        extra = 'Adding dummy regressor instead.';
      end

      msg = sprintf('%s %s not found in \n %s\n %s', ...
                    input1, ...
                    rmTrialTypeStr(variablesToConvolve{iCond}), ...
                    tsvFile, ...
                    extra);

      errorHandling(mfilename(), errorID, msg, true, opt.verbosity);

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

function [names, onsets, durations] = addDummyRegressor(names, onsets, durations)

  names{1, end + 1} = 'dummyRegressor';
  onsets{1, end + 1} = nan;
  durations{1, end + 1} = nan;

end
