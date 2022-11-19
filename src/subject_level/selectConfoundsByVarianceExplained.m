function newTsvContent = selectConfoundsByVarianceExplained(tsvContent, metadata, opt)
  %
  % Selects up to X of the fmriprep counfound regressors
  % from a specific tissue type that explain most of the variance
  %
  % USAGE::
  %
  %   newTsvContent = selectConfoundsByVarianceExplained(tsvContent, metadata, opt)
  %
  %
  % EXAMPLE::
  %
  %   tsvContent = bids.util.tsvread(tsvFile);
  %   metadata = bids.util.tsvread(jsonFile);
  %
  %   opt.columnsToSearch = {'c_comp_cor'};
  %   opt.tissueNames = {'CSF'};
  %   opt.maxNbRegPerTissue = 2;
  %   opt.prefix = 'keep_';
  %   newTsvContent = selectConfoundsByVarianceExplained(tsvContent, metadata, opt);
  %
  %

  % (C) Copyright 2022 bidspm developers

  % TODO: add a way to select the X confounds that explain at most Y % of variance

  if nargin == 2 || isempty(opt)
    opt.columnsToSearch = {'a_comp_cor_', 'c_comp_cor'};
    % tissues to regress out: for example 'WM','CSF' ou 'combined'
    opt.tissueNames = {'CSF', 'WM'};
    % max nb of PCA regressors per Tissue
    opt.maxNbRegPerTissue = [12 12];
    % prefix to append to column name
    opt.prefix = 'toinclude_';
  end

  columnsToSearch = opt.columnsToSearch;
  maxNbRegPerTissue = opt.maxNbRegPerTissue;
  tissueNames = opt.tissueNames;

  if length(maxNbRegPerTissue) ~= length(tissueNames)
    error('mismatch');
  end

  regressorCounter = zeros(1, length(tissueNames));
  nameRegressorsToInclude = {};
  valueRegressorsToInclude = [];

  tsvContentNames = fieldnames(tsvContent);

  i = 1;
  keepGoing = true;
  while i <= length(tsvContentNames) && keepGoing

    thisCol.name = tsvContentNames{i};
    thisCol.content = tsvContent.(thisCol.name);

    include = any(cellfun(@(x) bids.internal.starts_with(thisCol.name, x), ...
                          columnsToSearch));

    if include

      thisCol.tissue = metadata.(thisCol.name).Mask;

      for iTissue = 1:length(tissueNames)

        if strcmp(thisCol.tissue, tissueNames(iTissue)) && ...
                regressorCounter(iTissue) < maxNbRegPerTissue(iTissue)

          nameRegressorsToInclude{end + 1} = [thisCol.name '_' thisCol.tissue];  %#ok<*AGROW>
          valueRegressorsToInclude(:, end + 1) = thisCol.content;

          regressorCounter(iTissue) = regressorCounter(iTissue) + 1;
        end

      end

    end

    keepGoing = false;
    for iTissue = 1:length(tissueNames)
      if regressorCounter(iTissue) < maxNbRegPerTissue(iTissue)
        keepGoing = true;
        break
      end
    end

    i = i + 1;

  end

  newTsvContent = tsvContent;

  if isempty(nameRegressorsToInclude)
    warning('no regressor found');
    return
  end

  % add the included names & regressors at the end of the tsv structure
  for i = 1:length(nameRegressorsToInclude)
    newTsvContent.([opt.prefix nameRegressorsToInclude{i}]) = valueRegressorsToInclude(:, i);
  end

end
