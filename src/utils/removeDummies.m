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
  % (C) Copyright 2022 CPP_SPM developers

  isFile = @(x) exist(x, 'file');
  isPositive = @(x) x >= 0;

  default_metadata = struct('NumberOfVolumesDiscardedByUser', 0);
  default_force = false;
  default_verbose = true;

  p = inputParser;

  addRequired(p, 'inputFile', isFile);
  addRequired(p, 'dummyScans', isPositive);
  addOptional(p, 'metadata', default_metadata, @isstruct);
  addParameter(p, 'force', default_force, @islogical);
  addParameter(p, 'verbose', default_verbose, @islogical);

  parse(p, varargin{:});

  inputFile = p.Results.inputFile;
  dummyScans = p.Results.dummyScans;
  metadata = p.Results.metadata;
  force = p.Results.force;
  verbose = p.Results.verbose;

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

  jsonFile = spm_file(inputFile, 'ext', 'json');

  metadata.NumberOfVolumesDiscardedByUser = NumberOfVolumesDiscardedByUser;

  bids.util.jsonwrite(jsonFile, metadata);

end
