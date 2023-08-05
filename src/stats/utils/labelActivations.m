function tsvFile = labelActivations(varargin)
  %
  % Add MNI labels to a csv output file from SPM and saves it as TSV.
  %
  % Can choose which atlas to use.
  %
  % USAGE::
  %
  %   tsvFile = labelActivations(csvFile, 'atlas', 'Neuromorphometrics')
  %
  % :param csvFile:
  % :type  csvFile: path
  %
  % :type  atlas:   char
  % :param atlas:   Any of
  %
  %                 - `'Neuromorphometrics'``
  %                 - `'aal'``
  %                 - `'hcpex'``
  %                 - `'wang'``
  %                 - `'glasser'``
  %                 - `'visfatlas'``
  %
  %                 Defaults to ``'neuromorphometrics'``
  %
  % :returns: - :tsvFile: (path)
  %

  % (C) Copyright 2022 bidspm developers

  tsvFile = [];

  args = inputParser;

  defaultAtlas = 'Neuromorphometrics';

  addRequired(args, 'csvFile', @ischar);
  addParameter(args, 'atlas', defaultAtlas, @ischar);

  parse(args, varargin{:});

  csvFile = args.Results.csvFile;
  atlas = args.Results.atlas;

  atlasName = defaultAtlas;
  if ~strcmpi(atlas, 'neuromorphometrics')
    copyAtlasToSpmDir(atlas, 'verbose', false);
    switch lower(atlas)
      case 'aal'
        atlasName = 'AAL3v1_1mm';
      case 'hcpex'
        atlasName = 'HCPex';
      case 'glasser'
        atlasName = 'space-MNI152ICBM2009anlin_atlas-glasser_dseg';
      case 'visfatlas'
        atlasName = 'space-MNI_atlas-visfAtlas_dseg';
      case 'wang'
        atlasName = 'space-MNI_atlas-wang_dseg';
      otherwise
        logger('ERROR', 'unknown atlas', ...
               'filename', mfilename(), ...
               'id', 'labelActivations:UnknownAtlas');
    end
  end

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

  if isempty(newCSV.x)
    msg = sprintf('no significant voxels in file:\n\t%s', bids.internal.format_path(csvFile));
    id = 'noSignificantVoxel';
    logger('WARNING', msg, 'id', id, 'filename', mfilename());
    return
  end

  %% add MNI label
  spm_atlas('list', 'installed', '-refresh');
  xA = spm_atlas('load', atlasName);

  for  i = 1:numel(newCSV.x)
    newCSV.([atlas '_label']){i} = spm_atlas('query', xA, [newCSV.x(i), ...
                                                           newCSV.y(i), ...
                                                           newCSV.z(i)]');
  end

  tsvFile = bids.internal.file_utils(csvFile, 'ext', '.tsv');
  bids.util.tsvwrite(tsvFile, newCSV);

end
