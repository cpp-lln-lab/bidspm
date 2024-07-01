function [voxDim, opt] = getFuncVoxelDims(opt, subFuncDataDir, fileName)
  %
  % Get the resolution of an image and update the relevant field in the options.
  %
  % USAGE::
  %
  %   [voxDim, opt] = getFuncVoxelDims(opt, subFuncDataDir, fileName)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  % :param subFuncDataDir:
  % :type subFuncDataDir:
  % :param fileName:
  % :type fileName:
  %
  % :return: :voxDim:
  %           - :opt:
  %
  %
  %

  % (C) Copyright 2020 bidspm developers

  % get native resolution to reuse it at normalisation;
  if ~isempty(opt.funcVoxelDims) % If voxel dimensions is defined in the opt
    voxDim = opt.funcVoxelDims; % Get the dimension values
    return
  else
    hdr = spm_vol(fullfile(subFuncDataDir, fileName));
    M = hdr(1).mat;
    voxDim  = sqrt(sum(M(1:3, 1:3).^2));
    % Add it to opt.funcVoxelDims to have the same value for all sessions
    opt.funcVoxelDims = voxDim;
  end

end
