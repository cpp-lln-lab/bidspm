function fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile, runDuration, outputDir)
  %
  % Converts an events.tsv file to an onset file suitable for SPM subject level analysis.
  %
  % USAGE::
  %
  %   fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile)
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`src.defaults.checkOptions`.
  % :type  opt: structure
  %
  % :param tsvFile:
  % :type  tsvFile: char
  %
  % :param runDuration: Total duration of the run (in seconds). Optional.
  %                     Events occurring later than this will be excluded.
  % :type  runDuration: numeric
  %
  % :param outputDir: Path where to save ``onset.mat``. Optional.
  % :type  outputDir: path
  %
  % Use a BIDS stats model specified in a JSON file to:
  %
  % - loads events.tsv and apply the ``Node.Transformations`` to its content
  %
  % - extract the trials (onsets, durations)
  %   of the conditions that should be convolved
  %   as requested from ``Node.Model.HRF.Variables``
  %
  % It then stores them in in a .mat file
  % that can be fed directly in an SPM GLM batch as 'Multiple conditions'
  %
  % Parametric modulation can be specified via columns in the TSV
  % file starting with ``pmod_``.
  % These columns can be created via the use of ``Node.Transformations``.
  % Only polynomial 1 are supported.
  % More complex modulation should be precomputed via the Transformations.
  %
  % if ``opt.glm.useDummyRegressor`` is set to ``true``,
  % any missing condition will be replaced by a DummyRegressor.
  %
  % :return: fullpathOnsetFilename: (string) name of the output ``.mat`` file.
  %
  % EXAMPLE::
  %
  %         tsvFile = fullfile(pwd, 'data', 'sub-03_task-VisuoTact_run-02_events.tsv');
  %
  %         opt.model.file = fullfile(pwd, 'models', 'model-VisuoTact_smdl.json');
  %         opt.verbosity = 2;
  %         opt.glm.useDummyRegressor = false;
  %
  %         fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);
  %
  %
  % See also: createAndReturnOnsetFile, bids.transformers
  %

  % (C) Copyright 2019 bidspm developers

  if nargin < 3
    runDuration = nan;
  end

  if nargin < 4
    outputDir = '';
  end

  REQUIRED_COLUMNS = {'onset', 'duration'};

  [pth, file, ext] = spm_fileparts(tsvFile);
  tsv.file = validationInputFile(pth, [file, ext]);
  tsv.content = bids.util.tsvread(tsv.file);

  if ~isnan(runDuration)
    eventsToExclude = tsv.content.onset >= runDuration;
    columns = fieldnames(tsv.content);
    for iCol = 1:numel(columns)
      tsv.content.(columns{iCol})(eventsToExclude) = [];
    end
  end

  for i = 1:numel(REQUIRED_COLUMNS)
    if ~isfield(tsv.content, REQUIRED_COLUMNS{i})
      msg = sprintf(['''%s'' column is missing from file: %s', ...
                     '\nAvailable columns are: %s'], ...
                    REQUIRED_COLUMNS{i}, ...
                    tsv.file, ...
                    bids.internal.create_unordered_list(fieldnames(tsv.content)));
      logger('ERROR', msg, ...
             'filename', mfilename(), ...
             'id', 'missingTrialypeColumn');
    end
  end

  if ~all(isnumeric(tsv.content.onset))

    msg = sprintf('%s\n%s', 'Onset column contains non numeric values in file:', tsv.file);
    id = 'onsetsNotNumeric';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());

  end

  if ~all(isnumeric(tsv.content.duration))

    msg = sprintf('%s\n%s', 'Duration column contains non numeric values in file:', tsv.file);
    id = 'durationsNotNumeric';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());

  end

  if ~isfield(opt.model, 'bm')
    opt.model.bm = BidsModel('file', opt.model.file);
  end

  bm = opt.model.bm;

  varToConvolve = bm.getVariablesToConvolve();
  designMatrix = bm.getBidsDesignMatrix();
  designMatrix = removeIntercept(designMatrix);

  % conditions to be filled according to the conditions present in each run
  condToModel.names = {};
  condToModel.onsets = {};
  condToModel.durations = {};
  condToModel.pmod = struct('name', {''}, 'param', {}, 'poly', {});
  condToModel.idx = 1;

  % TODO get / apply transformers from a specific node
  transformers = bm.getBidsTransformers();
  tsv.content = bids.transformers(transformers, tsv.content);

  for iVar = 1:numel(varToConvolve)

    tokens = splitColumnCondtion(varToConvolve{iVar});

    % if the variable is present in namespace
    if ismember(tokens{1}, fieldnames(tsv.content))

      if ~ismember(varToConvolve{iVar}, designMatrix)
        % TODO does not account for edge cases where design matrix uses globbing pattern
        % like "face_*"
        % but variablesToConvolve only includes a subset of conditions
        % like "face_1" but not "face_2"
        continue
      end

      trialTypes = tsv.content.(tokens{1});
      condName = strjoin(tokens(2:end), '.');

      % deal with any globbing search like 'face_familiar*'
      hasGlobPattern = ~cellfun('isempty', regexp({condName}, '\*|\?'));

      if hasGlobPattern

        pattern = strrep(condName, '*', '[\_\-0-9a-zA-Z]*');
        pattern = strrep(pattern, '?', '[0-9a-zA-Z]?');
        pattern = regexify(pattern);
        containsPattern = ~cellfun('isempty', regexp(trialTypes, pattern));

        condList = unique(trialTypes(containsPattern));

        for iCdt = 1:numel(condList)

          condToModel = addCondition(opt, ...
                                     condList{iCdt}, ...
                                     trialTypes, ...
                                     tsv, ...
                                     condToModel, ...
                                     varToConvolve{iVar});

        end

      else

        condToModel = addCondition(opt, ...
                                   condName, ...
                                   trialTypes, ...
                                   tsv, ...
                                   condToModel, ...
                                   varToConvolve{iVar});

      end

    else

      if opt.glm.useDummyRegressor
        condToModel = addDummyRegressor(condToModel);
      end

      msg = sprintf('Variable "%s" not found in \n %s\n Adding dummy regressor instead.', ...
                    varToConvolve{iVar}, ...
                    tsv.file);
      id = 'variableNotFound';
      logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);

    end

  end

  %% save the onsets as a matfile
  [pth, file] = spm_fileparts(tsv.file);

  bf = bids.File(file);
  bf.suffix = 'onsets';
  bf.extension = '.mat';

  if ~strcmp(outputDir, '')
    pth = outputDir;
  end
  fullpathOnsetFilename = fullfile(pth, bf.filename);

  names = condToModel.names; %#ok<*NASGU>
  onsets = condToModel.onsets;
  durations = condToModel.durations;
  pmod = condToModel.pmod;

  save(fullpathOnsetFilename, ...
       'names', 'onsets', 'durations', 'pmod', ...
       '-v7');

end

function tokens = splitColumnCondtion(varToConvolve)
  % in case we get the column names with a dot separator
  tokens = regexp(varToConvolve, '\.', 'split');
end

function condToModel = addCondition(opt, condName, trialTypes, tsv, condToModel, varToConvolve)

  rows = find(strcmp(condName, trialTypes));

  msg = sprintf('   Condition "%s": %i trials found.\n', ...
                condName, ...
                numel(rows));
  logger('INFO', msg, 'options', opt, 'filename', mfilename());

  if ~isempty(rows)

    condToModel.names{1, condToModel.idx} = condName;
    condToModel.onsets{1, condToModel.idx} = tsv.content.onset(rows)';
    condToModel.durations{1, condToModel.idx} = tsv.content.duration(rows)';

    parametricModulations = opt.model.bm.getParametricModulations;
    if ~isempty(parametricModulations)
      condToModel = parametricModulation(condToModel, tsv, rows, parametricModulations, condName);
    end

    condToModel.idx = condToModel.idx + 1;

  else

    msg = sprintf('Trial type %s not found in \n\t%s\n', ...
                  varToConvolve, ...
                  tsv.file);
    id = 'trialTypeNotFound';
    logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);

    if opt.glm.useDummyRegressor
      condToModel = addDummyRegressor(condToModel);
    end

  end

end

function targetCondition = returnNameConditionToModulate(thisMod)
  % list all the conditions that are meant to be modulated
  % by this parametric modulators

  tokens = splitColumnCondtion(thisMod.Conditions);
  targetCondition = tokens;

  % in case we have single condition of the shape
  % column_name.condition_name
  if numel(tokens) == 1 && size(tokens{1}, 2) > 1
    targetCondition = tokens{1}(2);
  end

  % in case we have more than a single condition of the shape
  if size(tokens, 1) > 1
    for iTargetCondition = 1:size(tokens, 1)
      targetCondition{iTargetCondition} = tokens{iTargetCondition};
      if numel(tokens{iTargetCondition}) > 1
        targetCondition{iTargetCondition} = tokens{iTargetCondition}{1, 2};
      end
    end
  end

end

function conditionsToModel = parametricModulation(conditionsToModel, tsv, rows, parameMod, condName)
  % parametric modulation (pmod)
  %
  % skipped if parametric modulation amplitude == 1 for all onsets
  %
  % coerces NaNs into 1

  fields = fieldnames(tsv.content);

  for iMod = 1:numel(parameMod)

    if iscell(parameMod)
      thisMod = parameMod{iMod};
    elseif isstruct(parameMod)
      thisMod = parameMod(iMod);
    end

    for iValue = 1:numel(thisMod.Values)

      thisValue = thisMod.Values{iValue};

      targetCondition = returnNameConditionToModulate(thisMod);

      if ismember(thisValue, fields) && ...
              any(ismember(targetCondition, condName))

        amplitude = tsv.content.(thisValue)(rows);
        if iscellstr(amplitude) %#ok<ISCLSTR>
          amplitude = str2num(char(amplitude)); %#ok<ST2NM>
        end
        amplitude(isnan(amplitude)) = 1;
        if all(amplitude == 1)
          continue
        end

        poly = 1;
        if isfield(thisMod, 'PolynomialExpansion')
          poly = thisMod.PolynomialExpansion;
        end

        for iCond = 1:numel(thisMod.Conditions)

          tokens = splitColumnCondtion(thisMod.Conditions{iCond});
          conditionToModulate = tokens{1};
          if numel(tokens) == 2
            conditionToModulate = tokens{2};
          end

          if ismember(conditionToModulate, conditionsToModel.names)
            conditionsToModel.pmod(1, conditionsToModel.idx).name{iMod}  = thisMod.Name;
            conditionsToModel.pmod(end).param{iMod} = amplitude;
            conditionsToModel.pmod(end).poly{iMod}  = poly;
          end
        end

      end

    end

  end

end

function conditionsToModel = addDummyRegressor(conditionsToModel)

  conditionsToModel.names{1, end + 1} = 'dummyRegressor';
  conditionsToModel.onsets{1, end + 1} = nan;
  conditionsToModel.durations{1, end + 1} = nan;
  conditionsToModel.idx = conditionsToModel.idx + 1;

end
