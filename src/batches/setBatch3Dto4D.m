function matlabbatch = setBatch3Dto4D(matlabbatch, opt, volumesList, RT, outputName, dataType)
  %
  % Set the batch for 3D to 4D conversion
  %
  % USAGE::
  %
  %   matlabbatch = setBatch3Dto4D(matlabbatch, volumesList, RT, [outputName], [dataType])
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param volumesList: List of volumes to be converted in a single 4D brain
  % :type volumesList: array
  % :param outputName: The string that will be used to save the 4D brain
  % :type outputName: char
  % :param dataType: It identifies the data format conversion
  % :type dataType: integer
  % :param RT: It identifies the TR in seconds of the volumes
  %            to be written in the 4D file header
  % :type RT: float
  %
  % :return: :matlabbatch: (structure) The matlabbatch ready to run the spm job
  %
  % ``dataType``:
  %
  %   - 0:  SAME
  %   - 2:  UINT8   - unsigned char
  %   - 4:  INT16   - signed short
  %   - 8:  INT32   - signed int
  %   - 16: FLOAT32 - single prec. float
  %   - 64: FLOAT64 - double prec. float
  %

  % (C) Copyright 2020 bidspm developers

  if nargin < 6 || isempty(dataType)
    dataType = 0;
  end

  if nargin < 5 || isempty(outputName)
    outputName = deblank(volumesList(1, :));
    [pth, filename, ext] = spm_fileparts(outputName);
    outputName = fullfile(pth, [filename, '_4D', ext]);
  end

  printBatchName('3D to 4D conversion', opt);

  matlabbatch{end + 1}.spm.util.cat.vols = volumesList;
  matlabbatch{end}.spm.util.cat.name = outputName;
  matlabbatch{end}.spm.util.cat.dtype = dataType;
  matlabbatch{end}.spm.util.cat.RT = RT;

end
