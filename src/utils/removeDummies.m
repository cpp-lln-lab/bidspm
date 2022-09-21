function removeDummies(varargin)
  %
  % Short description of what the function does goes here.
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
      errorHandling(mfilename(), 'dummiesAlreadyRemoved', msg, true, verbose);

      return

    else
      numberOfVolumeToDiscard = dummyScans;
      NumberOfVolumesDiscardedByUser = NumberOfVolumesDiscardedByUser + dummyScans;

    end

  end

  volumeSplicing(inputFile, 1:numberOfVolumeToDiscard);

  if isZipped(inputFile)
    inputFile = spm_file(inputFile, 'ext', '');
  end
  jsonFile = spm_file(inputFile, 'ext', 'json');

  metadata.NumberOfVolumesDiscardedByUser = NumberOfVolumesDiscardedByUser;

  bids.util.jsonwrite(jsonFile, metadata);

end
