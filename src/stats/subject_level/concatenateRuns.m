function [matlabbatch, nbScans] = concatenateRuns(matlabbatch, opt)
  % (C) Copyright 2023 bidspm developers

  if nargin < 2
    opt.glm.concatenateRuns = false;
  end

  if ~opt.glm.concatenateRuns
    return
  end

  repetitionTime = matlabbatch{1}.spm.stats.fmri_spec.timing.RT;

  nbScans = [];

  sess = matlabbatch{1}.spm.stats.fmri_spec.sess;

  % concatenate volumes
  files = {};
  for i = 1:numel(sess)
    [pth, basename, ext] = fileparts(sess(i).scans{1});
    new_vols = cellstr(spm_select('ExtList', pth, [basename, ext]));
    nbScans(i) = numel(new_vols); %#ok<AGROW>
    files = cat(1, files, new_vols);
  end
  fmri_spec.sess.scans = {char(files)};

  fmri_spec.sess(1).multi{1} = concatenateOnsets(sess, repetitionTime, nbScans);

  fmri_spec.sess(1).multi_reg{1} = concatenateConfounds(sess);

  matlabbatch{1}.spm.stats.fmri_spec = fmri_spec;
end
