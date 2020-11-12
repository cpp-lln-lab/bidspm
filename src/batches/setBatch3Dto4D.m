% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatch3Dto4D(volumesList, outputName, dataType, RT)
  %
  % Set the batch for 3D to 4D conversion
  %
  % USAGE:: 
  %
  %   matlabbatch = setBatch3Dto4D(volumesList, outputName, dataType, RT)
  %
  % :param volumesList: List of volumes to be converted in a single 4D brain
  % :type volumesList: array
  % :param outputName: Obligatory argument. The string that will be used to save the 4D brain
  % :type outputName: string
  % :param dataType: Obligatory argument. It identifys the data format conversion
  % :type dataType: integer
  % :param RT: Obligatory argument. It identifys the TR in secof the volumes to be written in the
  %            4D file header
  % :type RT: float
  %
  % :returns: - :matlabbatch: (struct) The matlabbath ready to run the spm job

  fprintf(1, 'PREPARING: 3D to 4D conversion\n');

  matlabbatch{1}.spm.util.cat.vols = volumesList;
  matlabbatch{1}.spm.util.cat.name = outputName;
  matlabbatch{1}.spm.util.cat.dtype = dataType;
  matlabbatch{1}.spm.util.cat.RT = RT;

end
