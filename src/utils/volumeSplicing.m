function outputFile = volumeSplicing(varargin)
  %
  % Removes specific set of volumes from a nifti time series.
  %
  % USAGE::
  %
  %   outputFileFullPath = volumeSplicing(inputFile, volumesToRemove)
  %
  % :param inputFile:
  % :type inputFile: path
  %
  % :param volumesToRemove:
  % :type volumesToRemove: 1xn or nX1 array
  %
  % :param outputFile: optional parameter. default: will overwrite
  % ``inputFile``. If only a filename is given, the file will be created in the
  % same folder as the input file.
  % :type outputFile: string
  %
  % :returns: - :outputFileFullPath:
  %
  % Example::
  %
  %   outputFileFullPath = volumeSplicing(inputFile, volumesToRemove, 'outputFile', 'foo.nii.gz');
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;

  default_outputFile = '';

  isFile = @(x) (exist(x, 'file') == 2);
  isArrayPositive = @(x) (isnumeric(x) && all(x > 0));

  addRequired(p, 'inputFile', isFile);
  addRequired(p, 'volumesToRemove', isArrayPositive);
  addParameter(p, 'outputFile', default_outputFile, @ischar);

  parse(p, varargin{:});

  %% Wrangle inputs

  inputFile = p.Results.inputFile;
  volumesToRemove = p.Results.volumesToRemove;
  outputFile = p.Results.outputFile;
  if strcmp(outputFile, '')
    outputFile = inputFile;
  end

  isInputZipped = isZipped(inputFile);
  if isInputZipped
    % TODO fix for octave as unzipping will delete original
    gunzip(inputFile);
    inputFile = spm_file(inputFile, 'ext', '');
  end

  volumesToRemove = unique(volumesToRemove);

  isOutputZipped = isZipped(outputFile);
  if isOutputZipped
    outputFile = spm_file(outputFile, 'ext', '');
  end
  if isempty(spm_fileparts(outputFile))
    outputFile = spm_file(outputFile, 'path', spm_fileparts(inputFile));
  end

  %% Splice volumes out
  threeDimFiles = spm_file_split(inputFile);
  V = threeDimFiles;
  V(volumesToRemove) = [];
  spm_file_merge(V, outputFile);
  spm_unlink(threeDimFiles.fname);

  %% Wrangle outputs
  if isInputZipped
    gzip(inputFile);
    delete(inputFile);
  end

  if strcmp(p.Results.outputFile, '')
    outputFile = p.Results.inputFile;
    return

  else
    if isOutputZipped
      gzip(outputFile);
      delete(outputFile);
      outputFile = spm_file(outputFile, 'ext', '.nii.gz');
    end

  end

end
