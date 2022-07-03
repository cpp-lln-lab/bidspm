function fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile)
  %
  % Converts an events.tsv file to an onset file suitable for SPM subject level analysis.
  %
  % USAGE::
  %
  %   fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See  also: checkOptions
  % :type opt: structure
  %
  % :param tsvFile:
  % :type tsvFile: char
  %
  % Use a BIDS stats model specified in a JSON file to:
  %
  % - loads events.tsv and apply the Node.Transformations to its content
  %
  % - extract the trials (onsets, durations)
  %   of the conditions that should be convolved
  %   as requested from Node.HRF.Variables field
  %
  % It then stores them in in a .mat file
  % that can be fed directly in an SPM GLM batch as 'Multiple conditions'
  %
  % Parametric modulation can be specified via columns in the TSV
  % file starting with ``pmod_``.
  % These columns can be created via the use of Node.Transformations.
  % Only polynomial 1 are supported.
  % More complex modulation should be precomputed via the Transformations.
  %
  % if ``opt.glm.useDummyRegressor`` is set to ``true``, any missing condition
  % will be replaced by a DummyRegressor.
  %
  % :returns: :fullpathOnsetFilename: (string) name of the output ``.mat`` file.
  %
  % See also: createAndReturnOnsetFile, bids.transformers
  %
  % (C) Copyright 2019 CPP_SPM developers

  %
  [pth, file, ext] = spm_fileparts(tsvFile);
  tsvFile = validationInputFile(pth, [file, ext]);

  tsvContent = bids.util.tsvread(tsvFile);

  if ~all(isnumeric(tsvContent.onset))

    errorID = 'onsetsNotNumeric';
    msg = sprintf('%s\n%s', 'Onset column contains non numeric values in file:', tsvFile);
    errorHandling(mfilename(), errorID, msg, false, opt.verbosity);

  end

  if ~all(isnumeric(tsvContent.duration))

    errorID = 'durationsNotNumeric';
    msg = sprintf('%s\n%s', 'Duration column contains non numeric values in file:', tsvFile);
    errorHandling(mfilename(), errorID, msg, false, opt.verbosity);

  end

  variablesToConvolve = opt.model.bm.getVariablesToConvolve();
  designMatrix = opt.model.bm.getBidsDesignMatrix();
  designMatrix = removeIntercept(designMatrix);

  % create empty cell to be filled in according to the conditions present in each run
  names = {};
  onsets = {};
  durations = {};
  pmod = struct('name', {''}, 'param', {}, 'poly', {});

  if ~isfield(opt.model, 'bm')
    opt.model.bm = BidsModel('file', opt.model.file);
  end
  % TODO get / apply transformers from a specific node
  transformers = opt.model.bm.getBidsTransformers();
  tsvContent = bids.transformers(transformers, tsvContent);

  conditionIdx = 1;

  for iCond = 1:numel(variablesToConvolve)

    trialTypeNotFound = false; % should be dead code by now
    variableNotFound = false;
    extra = '';

    % first assume the input is from events.tsv
    tokens = regexp(variablesToConvolve{iCond}, '\.', 'split');

    % if the variable is present in namespace
    if ismember(tokens{1}, fieldnames(tsvContent))

      trialTypes = tsvContent.(tokens{1});
      conditionName = strjoin(tokens(2:end), '.');

      rows = find(strcmp(conditionName, trialTypes));

      printToScreen(sprintf('   Condition %s: %i trials found.\n', ...
                            conditionName, ...
                            numel(rows)), ...
                    opt);

      if ~isempty(rows)

        if ~ismember(variablesToConvolve{iCond}, designMatrix)
          continue
        end

        names{1, conditionIdx} = conditionName;
        onsets{1, conditionIdx} = tsvContent.onset(rows)'; %#ok<*AGROW,*NASGU>
        durations{1, conditionIdx} = tsvContent.duration(rows)';
        pmod = parametricModulation(pmod, tsvContent, rows, conditionIdx);

        conditionIdx = conditionIdx + 1;

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
        conditionIdx = conditionIdx + 1;
      end

      msg = sprintf('%s %s not found in \n %s\n %s', ...
                    input1, ...
                    variablesToConvolve{iCond}, ...
                    tsvFile, ...
                    extra);

      errorHandling(mfilename(), errorID, msg, true, opt.verbosity);

    end

  end

  %% save the onsets as a matfile
  [pth, file] = spm_fileparts(tsvFile);

  bf = bids.File(file);
  bf.suffix = 'onsets';
  bf.extension = '.mat';

  fullpathOnsetFilename = fullfile(pth, bf.filename);

  save(fullpathOnsetFilename, ...
       'names', 'onsets', 'durations', 'pmod', ...
       '-v7');

end

function pmod = parametricModulation(pmod, tsvContent, rows, conditionIdx)
  % parametric modulation (pmod)
  %
  % skipped if parametric modulation is 1 for all onsets
  %
  % coerces NaNs into 1

  fields = fieldnames(tsvContent);
  pmodIdx = ~cellfun('isempty', regexp(fields, '^pmod_.*', 'match'));
  pmodIdx = find(pmodIdx);

  for iMod = 1:numel(pmodIdx)

    thisMod = fields{pmodIdx(iMod)};

    amplitude = tsvContent.(thisMod)(rows);
    amplitude(isnan(amplitude)) = 1;

    if ~all(amplitude == 1)
      pmod(1, conditionIdx).name{iMod}  = strrep(thisMod, 'pmod_', '');
      pmod(end).param{iMod} = amplitude;
      pmod(end).poly{iMod}  = 1;
    end

  end
end

function [names, onsets, durations] = addDummyRegressor(names, onsets, durations)

  names{1, end + 1} = 'dummyRegressor';
  onsets{1, end + 1} = nan;
  durations{1, end + 1} = nan;

end
