% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function fullpathOnsetFileName = convertOnsetTsvToMat(opt, tsvFile)
  %% Converts a tsv file to an onset file suitable for SPM ffx analysis
  % The scripts extracts the conditions' names, onsets, and durations, and
  % converts them to TRs (time unit) and saves the onset file to be used for
  % SPM
  %
  [pth, file, ext] = spm_fileparts(tsvFile);
  tsvFile = validationInputFile(pth, [file, ext]);

  % Read the tsv file
  fprintf('reading the tsv file : %s \n', tsvFile);
  t = spm_load(tsvFile);

  if ~isfield(t, 'trial_type')

    errorStruct.identifier = 'convertOnsetTsvToMat:noTrialType';
    errorStruct.message = sprintf('%s\n%s', ...
                                  'There was no trial_type field in this file:', ...
                                  tsvFile);
    error(errorStruct);

  end

  conds = t.trial_type; % assign all the tsv information to a variable called conds.

  % identify where the conditions to include that are specificed in the 'un' step of the
  % model file
  model = spm_jsonread(opt.model.file);

  for runIdx = 1:numel(model.Steps)
    step = model.Steps(runIdx);
    if iscell(step)
      step = step{1};
    end
    if strcmp(step.Level, 'run')
      break
    end
  end

  isTrialType = strfind(step.Model.X, 'trial_type.');

  % for each condition
  for iCond = 1:numel(isTrialType)

    if isTrialType{iCond}

      conditionName = strrep(step.Model.X{iCond}, ...
                             'trial_type.', ...
                             '');

      % Get the index of each condition by comparing the unique names and
      % each line in the tsv files
      idx = find(strcmp(conditionName, conds));

      % Get the onset and duration of each condition
      names{1, iCond} = conditionName;
      onsets{1, iCond} = t.onset(idx)'; %#ok<*AGROW,*NASGU>
      durations{1, iCond} = t.duration(idx)';

    end
  end

  % save the onsets as a matfile
  [pth, file] = spm_fileparts(tsvFile);

  fullpathOnsetFileName = fullfile(pth, ['onsets_' file '.mat']);

  save(fullpathOnsetFileName, ...
       'names', 'onsets', 'durations', ...
       '-v7');

end
