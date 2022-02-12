function removeDummies(varargin)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   removeDummies(inputFile, dummyScans, metadata, 'force', false)
  %
  % :param foo: obligatory argument. Lorem ipsum dolor sit amet,
  % :type foo: cell
  %
  % :param faa: optional argument. Lorem ipsum dolor sit amet,
  % :type faa: structure
  %
  % :param fii: parameter. default: ``boo``
  % :type fii: string
  %
  % :returns: - :foo: (type) (dimension)
  %           - :faa: (type) (dimension)
  %           - :fii: (type) (dimension)
  %
  % Example::
  %
  % (C) Copyright 2022 CPP_SPM developers

  isFile = @(x) exist(x, 'file');
  isPositive = @(x) x >= 0;

  default_metadata = struct('NumberOfVolumesDiscardedByUser', 0);
  default_force = false;

  p = inputParser;

  addRequired(p, 'inputFile', isFile);
  addRequired(p, 'dummyScans', isPositive);
  addOptional(p, 'metadata', default_metadata, @isstruct);
  addParameter(p, 'force', default_force, @islogical);

  parse(p, varargin{:});

  inputFile = p.Results.inputFile;
  dummyScans = p.Results.dummyScans;
  metadata = p.Results.metadata;
  force = p.Results.force;

  isZipped = strcmp(spm_file(inputFile, 'ext'), 'gz');
  if isZipped
    % TODO fix for octave as unzipping will delete original
    gunzip(inputFile);
    inputFile = spm_file(inputFile, 'ext', '');
  end

  NumberOfVolumesDiscardedByUser = 0;
  if isfield(metadata, 'NumberOfVolumesDiscardedByUser')
    NumberOfVolumesDiscardedByUser = metadata.NumberOfVolumesDiscardedByUser;
  end

  if NumberOfVolumesDiscardedByUser < dummyScans
    numberOfVolumeToDiscard = dummyScans - NumberOfVolumesDiscardedByUser;
    NumberOfVolumesDiscardedByUser = dummyScans;

  elseif NumberOfVolumesDiscardedByUser >= dummyScans

    if ~force
      msg = sprintf(['NumberOfVolumesDiscardedByUser = %i for file\n%s.\n', ...
                     'Will not remove additional volumes, ', ...
                     'unless the ''force'' parameter is used.'], ...
                    metadata.NumberOfVolumesDiscardedByUser, ...
                    inputFile);
      errorHandling(mfilename(), 'dummiesAlreadyRemoved', msg, true, true);

      return

    else
      numberOfVolumeToDiscard = dummyScans;
      NumberOfVolumesDiscardedByUser = NumberOfVolumesDiscardedByUser + dummyScans;

    end

  end

  threeDimFiles = spm_file_split(inputFile);
  V = threeDimFiles;
  V(1:numberOfVolumeToDiscard) = [];
  spm_file_merge(V, inputFile);
  spm_unlink(threeDimFiles.fname);

  if isZipped
    gzip(inputFile);
    delete(inputFile);
  end

  jsonFile = spm_file(inputFile, 'ext', 'json');

  metadata.NumberOfVolumesDiscardedByUser = NumberOfVolumesDiscardedByUser;

  bids.util.jsonwrite(jsonFile, metadata);

end
