function [anat_normalized_file, anatRange] = return_normalized_anat_file(opt, subLabel)
  %
  % (C) Copyright 2021 Remi Gau

  [BIDS, opt] = getData(opt);
  [~, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);
  anat_normalized_file = spm_select('FPList', ...
                                    anatDataDir, ...
                                    '^wm.*skullstripped.nii$');

  hdr = spm_vol(anat_normalized_file);
  vol = spm_read_vols(hdr);

  anatRange = [min(vol(:)) max(vol(:))];

end
