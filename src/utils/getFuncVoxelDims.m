function [voxDim, opt] = getFuncVoxelDims(opt, subFuncDataDir, fileName)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [voxDim, opt] = getFuncVoxelDims(opt, subFuncDataDir, fileName)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  % :param subFuncDataDir:
  % :type subFuncDataDir:
  % :param fileName:
  % :type fileName:
  %
  % :returns: - :voxDim:
  %           - :opt:
  %
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  % get native resolution to reuse it at normalisation;
  if ~isempty(opt.funcVoxelDims) % If voxel dimensions is defined in the opt
    voxDim = opt.funcVoxelDims; % Get the dimension values
    return
  else
    hdr = spm_vol(fullfile(subFuncDataDir, fileName));
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
