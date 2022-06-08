function tsvFile = labelActivations(varargin)
  %
  % Adds MNI labels to a csv output file from SPM
  %
  % USAGE::
  %
  %   tsvFile = labelActivations(csvFile)
  %
  % :param csvFile:
  % :type csvFile: path
  %
  % :returns: - :tsvFile: (path)
  %
  % (C) Copyright 2022 CPP_SPM developers

  % The code goes below

  args = inputParser;

  addRequired(args, 'csvFile', @ischar);

  parse(args, varargin{:});

  csvFile = args.Results.csvFile;

  %% renaming headers to have only one row
  % combine 1rst and 2nd row
  CSV = bids.util.tsvread(csvFile);

  headers = fieldnames(CSV);

  columnIdx = @(x) find(~cellfun('isempty', regexp(headers, ['^' x '.*'], 'match')));
  coerce = @(x) regexprep(x, '[^a-zA-Z0-9_]', '_');

  set = columnIdx('set');
  for i = 1:numel(set)
    newCSV.(['set_' coerce(CSV.(headers{set(i)}){1})]) = CSV.(headers{set(i)})(2:end);
  end

  cluster = columnIdx('cluster');
  for i = 1:numel(cluster)
    newCSV.(['cluster_' coerce(CSV.(headers{cluster(i)}){1})]) = CSV.(headers{cluster(i)})(2:end);
  end

  peak = columnIdx('peak');
  for i = 1:numel(peak)
    newCSV.(['peak_' coerce(CSV.(headers{peak(i)}){1})]) = CSV.(headers{peak(i)})(2:end);
  end

  coordinates = columnIdx('x');
  label = {'x', 'y', 'z'};
  for i = 1:numel(coordinates)
    newCSV.(label{i}) = str2double(CSV.(headers{coordinates(i)})(2:end));
  end

  %% add MNI label
  %   L = spm_atlas('list');
  xA = spm_atlas('load', 'Neuromorphometrics');

  for  i = 1:numel(newCSV.x)
    newCSV.neuromorphometric_label{i} = spm_atlas('query', xA, [newCSV.x(i), ...
                                                                newCSV.y(i), ...
                                                                newCSV.z(i)]');
  end

  tsvFile = bids.internal.file_utils(csvFile, 'ext', '.tsv');
  bids.util.tsvwrite(tsvFile, newCSV);

end
