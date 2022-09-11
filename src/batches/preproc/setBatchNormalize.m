function matlabbatch = setBatchNormalize(matlabbatch, deformField, voxDim, imgToResample)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchNormalize(matlabbatch [, deformField] [, voxDim] [, imgToResample])
  %
  % :param matlabbatch:
  % :type  matlabbatch: structure
  %
  % :param deformField:
  % :type  deformField:
  %
  % :param voxDim:
  % :type  voxDim:
  %
  % :param imgToResample:
  % :type  imgToResample:
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2019 bidspm developers

  if nargin > 1 && ~isempty(deformField)
    matlabbatch{end + 1}.spm.spatial.normalise.write.subj.def(1) = deformField;
  end

  if nargin > 2 && ~isempty(voxDim)
    matlabbatch{end}.spm.spatial.normalise.write.woptions.vox = voxDim;
  end

  if nargin > 3 && ~isempty(imgToResample)
    matlabbatch{end}.spm.spatial.normalise.write.subj.resample(1) = imgToResample;
  end

  % The following lines are commented out because those parameters
  % can be set in the spm_my_defaults.m
  % matlabbatch{iJob}.spm.spatial.normalise.write.woptions.bb = ...
  %  [-78 -112 -70 ; 78 76 85];
  % matlabbatch{iJob}.spm.spatial.normalise.write.woptions.interp = 4;
  % matlabbatch{iJob}.spm.spatial.normalise.write.woptions.prefix = ...
  %  spm_get_defaults('normalise.write.prefix');

end
