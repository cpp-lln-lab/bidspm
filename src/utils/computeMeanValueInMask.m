function value = computeMeanValueInMask(image, mask)
  %
  % USAGE::
  %
  %   value = computeMeanValueInMask(image, mask)
  %
  % image: image filename
  % mask: mask filename
  %
  %

  % (C) Copyright 2021 bidspm developers

  % TODO what is returned by this when image is a 4D time series?
  % write test

  hdr = spm_vol(mask);
  vol = spm_read_vols(hdr);
  [x, y, z]  = ind2sub(size(vol), find(vol));
  data     = spm_get_data(image, [x, y, z]');
  value    = nanmean(data);

end
