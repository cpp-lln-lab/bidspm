function matFile = concatenateConfounds(sess)
  % Concatenate content of matfiles with confounds across runs.
  %
  % USAGE::
  %
  %    matFile = concatenateConfounds(sess)
  %
  %
  % :param sess: Need at least a 'multi' field.
  %              Taken from a first level GLM
  %              ``matlabbatch{1}.spm.stats.fmri_spec.sess``
  % :type  sess: structure with numel == nb of runs
  %

  % (C) Copyright 2023 bidspm developers

  if numel(sess) == 1
    matFile = sess(1).multi_reg{1};
    return
  end

  bf = bids.File(sess(1).multi_reg{1});
  subLabel = bf.entities.sub;

  % collect condition names
  allConfounds = {};
  allTasks = {};
  for iSess = 1:numel(sess)
    load(sess(iSess).multi_reg{1}, 'names');
    allConfounds = cat(2, allConfounds, names); %#ok<*NODEF,*USENS>
    bf = bids.File(sess(iSess).multi_reg{1});
    allTasks{end + 1} = bf.entities.task; %#ok<*AGROW>
  end

  % initialize
  confounds.names = unique(allConfounds);
  confounds.R = [];

  clear all_conditions;

  % do the concatenations
  for iSess = 1:numel(sess)

    load(sess(iSess).multi_reg{1}, 'names', 'R');

    for iCdt = 1:numel(confounds.names)

      idx = ismember(names, confounds.names{iCdt});
      if ~any(idx)
        tmp(:, iCdt) = zeros(size(R, 1), 1);
      else

        tmp(:, iCdt) = R(:, idx);
      end

    end

    confounds.R = cat(1, confounds.R, tmp);

    delete(sess(iSess).multi_reg{1});

    clear names R tmp;

  end

  outputDir = fileparts(sess(iSess).multi_reg{1});

  input.suffix = 'timeseries';
  input.ext = '.mat';
  input.entities = struct('sub', subLabel, ...
                          'task', bids.internal.camel_case(strjoin(allTasks)), ...
                          'desc', 'confounds');

  bf = bids.File(input, 'use_schema', false);

  matFile = fullfile(outputDir, bf.filename);

  names = confounds.names; %#ok<*NASGU>
  R = confounds.R;

  save(matFile, 'names', 'R', '-v7');

end
