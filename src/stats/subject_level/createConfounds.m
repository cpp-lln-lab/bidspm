function [names, R] = createConfounds(tsvContent, designMatrix, maxNbVols)
  %
  % Creates confounds to save in a mat file for easy ingestion by SPM
  % in the subject level GLM.
  %
  % .. note::
  %
  %     Any NaN value will be converted to 0.
  %
  % USAGE::
  %
  %   [names, R] = createConfounds(tsvContent, designMatrix, maxNbVols)
  %
  % :param tsvContent: output of spm_load or bids.util.tsvread
  % :type  tsvContent: structure
  %
  % :param designMatrix: conditions included in the design matrix
  % :type  designMatrix: cell string
  %
  % :param maxNbVols: number of volumes included in that run to limit
  %                   the number of rows in the confound regressors.
  %                   If ``Inf`` all rows will be included.
  %                   Default to ``Inf``.
  % :type  maxNbVols: positive integer or Inf
  %
  % :returns: :names:
  % :returns: :R:
  %
  % EXAMPLE::
  %
  %         tsvFile = fullfile(some_path, 'sub-01_task-test_desc-confounds_regressors.tsv');
  %         tsvContent = bids.util.tsvread(tsvFile);
  %
  %         designMatrix = {'trial_type.VisMot'
  %                         'trial_type.VisStat'
  %                         'trial_type.missing_condition'
  %                         'trans_x'
  %                         'trans_y'
  %                         'trans_z'
  %                         'rot_x'
  %                         'rot_y'
  %                         'rot_z'};
  %
  %         [names, R] = createConfounds(tsvContent, designMatrix, 200);
  %
  %         names
  %         >>>{'trans_x'
  %             'trans_y'
  %             'trans_z'
  %             'rot_x'
  %             'rot_y'
  %             'rot_z'};
  %
  %         size(R)
  %         >>> 200, 6
  %
  % See also: setBatchSubjectLevelGLMSpec, createConfounds
  %

  % (C) Copyright 2021 bidspm developers

  if nargin < 3
    maxNbVols = Inf;
  end

  designMatrix = removeIntercept(designMatrix);

  % basic filter based on model content
  headers = fieldnames(tsvContent);
  names = intersect(designMatrix, headers);

  % deal with any globbing search like 'motion_outlier*'
  hasGlobPattern = ~cellfun('isempty', regexp(designMatrix, '\*|\?'));
  if any(hasGlobPattern)
    idx = find(hasGlobPattern);
    for i = 1:numel(idx)
      pattern = designMatrix{idx(i)};
      pattern = strrep(pattern, '*', '[\_\-0-9a-zA-Z]*');
      pattern = strrep(pattern, '?', '[0-9a-zA-Z]?');
      pattern = regexify(pattern);
      containsPattern = regexp(headers, pattern);
      names = cat(1, names, headers(~cellfun('isempty', containsPattern)));
    end
  end

  R = [];
  for col = 1:numel(names)

    tmp = tsvContent.(names{col});

    if maxNbVols ~= Inf && ...
       numel(tsvContent.(names{col})) > maxNbVols
      tmp = tmp(1:maxNbVols);
    end

    tmp(isnan(tmp)) = 0;

    R(:, col) = tmp;

  end

end
