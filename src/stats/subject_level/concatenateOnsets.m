function matFile = concatenateOnsets(sess, repetitionTime, nbScans)
  % Concatenate onsets and durations across runs.
  %
  % USAGE::
  %
  %    matFile = concatenateOnsets(sess, repetitionTime, nbScans)
  %
  %
  % :param sess: need at least a 'multi' field
  % :type  sess: structure with numel == nb of runs
  %
  % :param repetitionTime:
  % :type  repetitionTime: int
  %
  % :param nbScans:
  % :type  nbScans: array of int
  %

  % (C) Copyright 2023 bidspm developers

  if numel(sess) == 1
    matFile = sess(1).multi{1};
    return
  end

  bf = bids.File(sess(1).multi{1});
  subLabel = bf.entities.sub;

  % collect condition names
  allConditions = {};
  allTasks = {};
  for iSess = 1:numel(sess)
    load(sess(iSess).multi{1}, 'names');
    allConditions = cat(2, allConditions, names); %#ok<*NODEF,*USENS>
    bf = bids.File(sess(iSess).multi{1});
    allTasks{end + 1} = bf.entities.task; %#ok<*AGROW>
  end

  % initialize
  condToModel.names = unique(allConditions);
  for iCdt = 1:numel(condToModel.names)
    condToModel.onsets{1, iCdt} = [];
    condToModel.durations{1, iCdt} = [];
  end

  clear all_conditions;

  % do the concatenations
  for iSess = 1:numel(sess)

    offset = 0;
    if iSess > 1
      offset = nbScans(iSess) * repetitionTime;
    end

    load(sess(iSess).multi{1}, 'names', 'onsets', 'durations', 'pmod');

    if numel(pmod) > 1 && ~isempty(pmod.name)
      logger('ERROR', 'Concatenation of parametric modulation not impemented', ...
             'filename', mfilename(), 'id', 'paramModConcatNotImplemented');
    end

    for iCdt = 1:numel(condToModel.names)
      idx = ismember(names, condToModel.names{iCdt});
      if ~any(idx)
        continue
      end

      condToModel.onsets{1, iCdt} = cat(1, condToModel.onsets{1, iCdt}, ...
                                        onsets{idx} + offset);  %#ok<*IDISVAR>
      condToModel.durations{1, iCdt} = cat(1, condToModel.durations{1, iCdt}, ...
                                           durations{idx});
    end

    delete(sess(iSess).multi{1});

    clear names onsets durations;

  end

  % TODO pmod concatenation not supported
  condToModel.pmod = struct('name', {''}, 'param', {}, 'poly', {});

  outputDir = fileparts(sess(iSess).multi{1});

  input.suffix = 'onsets';
  input.ext = '.mat';
  input.entities = struct('sub', subLabel, ...
                          'task', bids.internal.camel_case(strjoin(allTasks)));

  bf = bids.File(input, 'use_schema', false);

  matFile = fullfile(outputDir, bf.filename);

  names = condToModel.names; %#ok<*NASGU>
  onsets = condToModel.onsets;
  durations = condToModel.durations;
  pmod = condToModel.pmod;

  save(matFile, ...
       'names', 'onsets', 'durations', 'pmod', ...
       '-v7');

end
