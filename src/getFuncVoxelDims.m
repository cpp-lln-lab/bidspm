% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function [voxDim, opt] = getFuncVoxelDims(opt, subFuncDataDir, prefix, fileName)
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
  % [voxDim, opt] = getFuncVoxelDims(opt, subFuncDataDir, prefix, fileName)
  %
  %

  % get native resolution to reuse it at normalisation;
  if ~isempty(opt.funcVoxelDims) % If voxel dimensions is defined in the opt
    voxDim = opt.funcVoxelDims; % Get the dimension values
    return
  else
    % SPM Doesnt deal with nii.gz and all our nii should be unzipped
    % at this stage
    hdr = spm_vol(fullfile(subFuncDataDir, [prefix, fileName]));
    voxDim = diag(hdr(1).mat);
    % Voxel dimensions are not pure integers before reslicing, therefore
    % round the dimensions of the functional files to the 1st decimal point
    voxDim = abs(voxDim(1:3)');
    voxDim = round(voxDim * 10) / 10;
    % Add it to opt.funcVoxelDims to have the same value for
    % all subjects and sessions
    opt.funcVoxelDims = voxDim;
  end

end
