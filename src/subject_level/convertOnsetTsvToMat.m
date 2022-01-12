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

  % Read the tsv file
  msg = sprintf('reading the tsv file : %s \n', tsvFile);
  printToScreen(msg, opt);
  t = bids.util.tsvread(tsvFile);

  if ~isfield(t, 'trial_type')

    msg = sprintf('%s\n%s', ...
                  'There was no trial_type field in this file:', ...
                  tsvFile);
    id = 'noTrialType';
    errorHandling(mfilename(), id, msg, false, opt.verbosity);

  end

  conds = t.trial_type;

  % identify the conditions to convolve in the BIDS model
  variablesToConvolve = getVariablesToConvolve(opt.model.file, 'run');
  isTrialType = strfind(variablesToConvolve, 'trial_type.');

  % create empty cell to be filled in according to the conditions present in each run
  names = {};
  onsets = {};
  durations = {};

  % for each condition
  for iCond = 1:numel(isTrialType)

    if isTrialType{iCond}

      conditionName = strrep(variablesToConvolve{iCond}, ...
                             'trial_type.', ...
                             '');

      % Get the index of each condition by comparing the unique names and
      % each line in the tsv files
      idx = find(strcmp(conditionName, conds));

      if ~isempty(idx)
        % Get the onset and duration of each condition
        names{1, end + 1} = conditionName;
        onsets{1, end + 1} = t.onset(idx)'; %#ok<*AGROW,*NASGU>
        durations{1, end + 1} = t.duration(idx)';

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

        id = 'emptyTrialType';
        id = 'noTrialType';
        errorHandling(mfilename(), id, msg, true, opt.verbosity);

      end

    end
  end

  % save the onsets as a matfile
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
