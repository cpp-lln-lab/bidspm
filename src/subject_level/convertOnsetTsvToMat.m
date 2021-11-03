function fullpathOnsetFileName = convertOnsetTsvToMat(opt, tsvFile)
  %
  % Converts an events.tsv file to an onset file suitable for SPM subject level
  % analysis.
  %
  % The function extracts from the events.tsv file the trials (with type, onsets, and durations)
  % of th conditions of interest as requested in the model.json.
  % It then stores them in a .mat file that can be fed directly in an SPM GLM
  % batch.
  %
  % USAGE::
  %
  %   fullpathOnsetFileName = convertOnsetTsvToMat(opt, tsvFile)
  %
  % :param opt:
  % :type opt: structure
  % :param tsvFile:
  % :type tsvFile: string
  %
  % :returns: :fullpathOnsetFileName: (string) name of the output ``.mat`` file.
  %
  % (C) Copyright 2019 CPP_SPM developers

  %
  [pth, file, ext] = spm_fileparts(tsvFile);
  tsvFile = validationInputFile(pth, [file, ext]);

  % Read the tsv file
  msg = sprintf('reading the tsv file : %s \n', tsvFile);
  printToScreen(msg, opt);
  t = spm_load(tsvFile);

  if ~isfield(t, 'trial_type')

    msg = sprintf('%s\n%s', ...
                  'There was no trial_type field in this file:', ...
                  tsvFile);
    id = 'noTrialType';
    errorHandling(mfilename(), id, msg, false, opt.verbosity);

  end

  % assign all the tsv information to a variable called conds.
  conds = t.trial_type;

  % identify where the conditions to include that are specificed
  % in the run step of the model file

  X = getBidsDesignMatrix(opt.model.file, 'run');

  isTrialType = strfind(X, 'trial_type.');

  % create empty cell to be filled in according to the conditions present in each run
  names = {};
  onsets = {};
  durations = {};

  % for each condition
  for iCond = 1:numel(isTrialType)

    if isTrialType{iCond}

      conditionName = strrep(X{iCond}, ...
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
        msg = sprintf('No trial found for trial type %s in \n%s', conditionName, tsvFile);
        id = 'emptyTrialType';
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

  fullpathOnsetFileName = fullfile(pth, bidsFile.filename);

  save(fullpathOnsetFileName, ...
       'names', 'onsets', 'durations', ...
       '-v7');

end
