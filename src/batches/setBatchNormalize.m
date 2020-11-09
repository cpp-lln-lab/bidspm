% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchNormalize(matlabbatch, deformField, voxDim, imgToResample)
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
