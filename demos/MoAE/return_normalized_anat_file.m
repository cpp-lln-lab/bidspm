function [anat_normalized_file, anatRange] = return_normalized_anat_file(opt, subLabel)
  %
  % (C) Copyright 2021 Remi Gau

  [BIDS, opt] = getData(opt, opt.dir.preproc);
  opt.query.space = 'MNI';
  [anat_normalized_file, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);
  anat_normalized_file = fullfile(anatDataDir, anat_normalized_file);
  hdr = spm_vol(anat_normalized_file);
  vol = spm_read_vols(hdr);

  anatRange = [min(vol(:)) max(vol(:))];

end
