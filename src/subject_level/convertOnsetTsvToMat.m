% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function fullpathOnsetFileName = convertOnsetTsvToMat(opt, tsvFile)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  % Converts a tsv file to an onset file suitable for SPM ffx analysis
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

  % assign all the tsv information to a variable called conds.
  conds = t.trial_type; 

  % identify where the conditions to include that are specificed 
  % in the run step of the model file

  if isempty(opt.model.file)
    opt = createDefaultModel(BIDS, opt);
  end
  
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
