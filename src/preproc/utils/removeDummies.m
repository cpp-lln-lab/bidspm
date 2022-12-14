function removeDummies(varargin)
  %
  % Remove dummy scans from a time series and update file metadata.
  %
  % USAGE::
  %
  %   removeDummies(inputFile, dummyScans, metadata, 'force', false, 'verbose', true)
  %
  % :param inputFile:
  % :type inputFile: structure
  %
  % :param dummyScans: number of dummy scans to remove
  % :type dummyScans: positive integer
  %
  % :param metadata:
  % :type metadata: structure
  %
  % :param force:
  % :type force: boolean
  %
  % :param verbose:
  % :type verbose: boolean
  %
  %

  % (C) Copyright 2022 bidspm developers

  isFile = @(x) exist(x, 'file');
  isPositive = @(x) x >= 0;

  default_metadata = struct('NumberOfVolumesDiscardedByUser', 0);
  default_force = false;
  default_verbose = true;

  args = inputParser;

  addRequired(args, 'inputFile', isFile);
  addRequired(args, 'dummyScans', isPositive);
  addOptional(args, 'metadata', default_metadata, @isstruct);
  addParameter(args, 'force', default_force, @islogical);
  addParameter(args, 'verbose', default_verbose, @islogical);

  parse(args, varargin{:});

  inputFile = args.Results.inputFile;
  dummyScans = args.Results.dummyScans;
  metadata = args.Results.metadata;
  force = args.Results.force;

  verbose = args.Results.verbose;
  opt.verbosity = 0;
  if verbose
    opt.verbosity = 2;
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
      id = 'dummiesAlreadyRemoved';
      logger('WARNING', msg, 'options', opt, 'filename', mfilename(), 'id', id);

      return

    else
      numberOfVolumeToDiscard = dummyScans;
      NumberOfVolumesDiscardedByUser = NumberOfVolumesDiscardedByUser + dummyScans;

    end

  end

  volumeSplicing(inputFile, 1:numberOfVolumeToDiscard);

  msg = sprintf('\nRemoved %i volumes from file:\n%s', ...
                numberOfVolumeToDiscard, inputFile);
  logger('INFO', msg, 'options', opt, 'filename', mfilename());

  if isZipped(inputFile)
    inputFile = spm_file(inputFile, 'ext', '');
  end
  jsonFile = spm_file(inputFile, 'ext', 'json');

  metadata.NumberOfVolumesDiscardedByUser = NumberOfVolumesDiscardedByUser;

  bids.util.jsonwrite(jsonFile, metadata);

end
