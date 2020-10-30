% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function matlabbatch = setBatchNormalize(matlabbatch, deformField, voxDim, imgToResample)

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
