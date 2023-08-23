function [matlabbatch, nbScans] = concatenateRuns(matlabbatch, opt)
  % Concatenate runs in the batch of a first level GLM.
  %
  % USAGE::
  %
  %    [matlabbatch, nbScans] = concatenateRuns(matlabbatch, opt)
  %
  %
  % :param matlabbatch:
  % :type  matlabbatch: struct
  %
  % :param opt:
  % :type  opt: struct
  %

  % (C) Copyright 2023 bidspm developers

  if nargin < 2
    opt.glm.concatenateRuns = false;
  end

  if ~opt.glm.concatenateRuns
    return
  end

  sess = matlabbatch{1}.spm.stats.fmri_spec.sess;

  if numel(sess) == 1
    return
  end

  repetitionTime = matlabbatch{1}.spm.stats.fmri_spec.timing.RT;

  [volumeList, nbScans] = concatenateImages(sess);
  fmri_spec.sess.scans = {volumeList};

  fmri_spec.sess(1).multi{1} = concatenateOnsets(sess, repetitionTime, nbScans);

  fmri_spec.sess(1).multi_reg{1} = concatenateConfounds(sess);

  fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
  fmri_spec.sess(1).cond = struct('name', {}, 'onset', {}, 'duration', {});

  hpf = unique([sess(:).hpf]);
  assert(numel(hpf) == 1);

  fmri_spec.sess(1).hpf =  hpf;

  matlabbatch{1}.spm.stats.fmri_spec = fmri_spec;
end
