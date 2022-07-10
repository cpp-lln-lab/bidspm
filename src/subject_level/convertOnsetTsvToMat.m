function fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile)
  %
  % Converts an events.tsv file to an onset file suitable for SPM subject level analysis.
  %
  % USAGE::
  %
  %   fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile)
  %
  % :param opt: Options chosen for the analysis.
  %             See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type  opt: structure
  %
  % :param tsvFile:
  % :type  tsvFile: char
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
  % :returns: :fullpathOnsetFilename: (string) name of the output ``.mat`` file.
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
  % (C) Copyright 2019 CPP_SPM developers

  [pth, file, ext] = spm_fileparts(tsvFile);
  tsv.file = validationInputFile(pth, [file, ext]);
  tsv.content = bids.util.tsvread(tsv.file);

  if ~all(isnumeric(tsv.content.onset))

    msg = sprintf('%s\n%s', 'Onset column contains non numeric values in file:', tsv.file);
    errorHandling(mfilename(), 'onsetsNotNumeric', msg, false, opt.verbosity);

  end

  if ~all(isnumeric(tsv.content.duration))

    msg = sprintf('%s\n%s', 'Duration column contains non numeric values in file:', tsv.file);
    errorHandling(mfilename(), 'durationsNotNumeric', msg, false, opt.verbosity);

  end

  if ~isfield(opt.model, 'bm')
    opt.model.bm = BidsModel('file', opt.model.file);
  end

  varToConvolve = opt.model.bm.getVariablesToConvolve();
  designMatrix = opt.model.bm.getBidsDesignMatrix();
  designMatrix = removeIntercept(designMatrix);

  % conditions to be filled according to the conditions present in each run
  condToModel.names = {};
  condToModel.onsets = {};
  condToModel.durations = {};
  condToModel.pmod = struct('name', {''}, 'param', {}, 'poly', {});
  condToModel.idx = 1;

  % TODO get / apply transformers from a specific node
  transformers = opt.model.bm.getBidsTransformers();
  tsv.content = bids.transformers(transformers, tsv.content);

  for iVar = 1:numel(varToConvolve)

    % in case we get the column names with a dot separator
    tokens = regexp(varToConvolve{iVar}, '\.', 'split');

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

      msg = sprintf('Variable %s not found in \n %s\n Adding dummy regressor instead.', ...
                    varToConvolve{iVar}, ...
                    tsv.file);

      errorHandling(mfilename(), 'variableNotFound', msg, true, opt.verbosity);

    end

  end

  %% save the onsets as a matfile
  [pth, file] = spm_fileparts(tsv.file);

  bf = bids.File(file);
  bf.suffix = 'onsets';
  bf.extension = '.mat';

  fullpathOnsetFilename = fullfile(pth, bf.filename);

  names = condToModel.names; %#ok<*NASGU>
  onsets = condToModel.onsets;
  durations = condToModel.durations;
  pmod = condToModel.pmod;

  save(fullpathOnsetFilename, ...
       'names', 'onsets', 'durations', 'pmod', ...
       '-v7');

end

function condToModel = addCondition(opt, condName, trialTypes, tsv, condToModel, varToConvolve)

  rows = find(strcmp(condName, trialTypes));

  printToScreen(sprintf('   Condition %s: %i trials found.\n', ...
                        condName, ...
                        numel(rows)), ...
                opt);

  if ~isempty(rows)

    condToModel.names{1, condToModel.idx} = condName;
    condToModel.onsets{1, condToModel.idx} = tsv.content.onset(rows)';
    condToModel.durations{1, condToModel.idx} = tsv.content.duration(rows)';
    condToModel = parametricModulation(condToModel, tsv, rows);

    condToModel.idx = condToModel.idx + 1;

  else

    msg = sprintf('Trial type %s not found in \n\t%s\n', ...
                  varToConvolve, ...
                  tsv.file);

    errorHandling(mfilename(), 'trialTypeNotFound', msg, true, opt.verbosity);

    if opt.glm.useDummyRegressor
      condToModel = addDummyRegressor(condToModel);
    end

  end

end

function conditionsToModel = parametricModulation(conditionsToModel, tsv, rows)
  % parametric modulation (pmod)
  %
  % skipped if parametric modulation == 1 for all onsets
  %
  % coerces NaNs into 1

  fields = fieldnames(tsv.content);
  pmodIdx = ~cellfun('isempty', regexp(fields, '^pmod_.*', 'match'));
  pmodIdx = find(pmodIdx);

  for iMod = 1:numel(pmodIdx)

    thisMod = fields{pmodIdx(iMod)};

    amplitude = tsv.content.(thisMod)(rows);
    amplitude(isnan(amplitude)) = 1;

    if ~all(amplitude == 1)
      conditionsToModel.pmod(1, conditionsToModel.idx).name{iMod}  = strrep(thisMod, 'pmod_', '');
      conditionsToModel.pmod(end).param{iMod} = amplitude;
      conditionsToModel.pmod(end).poly{iMod}  = 1;
    end

  end
end

function conditionsToModel = addDummyRegressor(conditionsToModel)

  conditionsToModel.names{1, end + 1} = 'dummyRegressor';
  conditionsToModel.onsets{1, end + 1} = nan;
  conditionsToModel.durations{1, end + 1} = nan;
  conditionsToModel.idx = conditionsToModel.idx + 1;

end
