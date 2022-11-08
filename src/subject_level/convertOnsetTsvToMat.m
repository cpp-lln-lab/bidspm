% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function fullpathOnsetFileName = convertOnsetTsvToMat(opt, tsvFile)
  %
  % Converts an  events.tsv file to an onset file suitable for SPM subject level
  % analysis.
  % The scripts extracts the trial type, onsets, and durations, and
  % converts them and stores them in a mat file.
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
  % :returns: - :fullpathOnsetFileName: (string) name of the output `.mat` file.
  %

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

  % identify where the conditions to include that are specificed
  % in the run step of the model file
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
  
  columnsInTsv = fieldnames(t);

  % create empty cell to be filled in according to the conditions present in each run
  names = {};
  onsets = {};
  durations = {};

  % for each condition
  for iCond = 1:numel(step.Model.X)

      columnCond = regexp(step.Model.X{iCond}, '\.', 'split');
      
      if numel(columnCond) == 1
          continue;
      end
      
      columnName = columnCond{1};
      conditionName = columnCond{2};
      
      columnPresent = ismember(columnName, columnsInTsv);

    if columnPresent

        conds = t.(columnCond{1});

      % Get the index of each condition by comparing the unique names and
      % each line in the tsv files
      idx = find(strcmp(conditionName, conds));

      if ~isempty(idx)
        % Get the onset and duration of each condition
        names{1, end + 1} = conditionName;
        onsets{1, end + 1} = t.onset(idx)'; %#ok<*AGROW,*NASGU>
        durations{1, end + 1} = t.duration(idx)';
      else
        warning('No trial found for trial type %s in \n%s', conditionName, tsvFile);
      end

    end
  end

  % save the onsets as a matfile
  [pth, file] = spm_fileparts(tsvFile);

  fullpathOnsetFileName = fullfile(pth, ['onsets_' file '.mat']);

  save(fullpathOnsetFileName, ...
       'names', 'onsets', 'durations', ...
       '-v7');

end
