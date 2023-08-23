function [matlabbatch, nbScans] = concatenateRuns(matlabbatch, opt)
  % (C) Copyright 2023 bidspm developers

  if nargin < 2
    opt.glm.concatenateRuns = false;
  end

  if ~opt.glm.concatenateRuns
    return
  end

  repetitionTime = matlabbatch{1}.spm.stats.fmri_spec.timing.RT;

  sess = matlabbatch{1}.spm.stats.fmri_spec.sess;

  [volumeList, nbScans] = concatenateImages(sess);
  fmri_spec.sess.scans = {volumeList};

  fmri_spec.sess(1).multi{1} = concatenateOnsets(sess, repetitionTime, nbScans);

  fmri_spec.sess(1).multi_reg{1} = concatenateConfounds(sess);

  matlabbatch{1}.spm.stats.fmri_spec = fmri_spec;
end
