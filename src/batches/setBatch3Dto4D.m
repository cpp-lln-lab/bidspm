% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatch3Dto4D(volumesList, outputName, dataType, RT)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  % .. todo:
  %
  %    - item 1
  %    - item 2

  fprintf(1, 'PREPARING: 3D to 4D conversion\n');

  matlabbatch{1}.spm.util.cat.vols = volumesList;
  matlabbatch{1}.spm.util.cat.name = outputName;
  matlabbatch{1}.spm.util.cat.dtype = dataType;
  matlabbatch{1}.spm.util.cat.RT = RT;

end
