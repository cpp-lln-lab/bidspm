function roiName = thresholdToMask(sourceImage, threshold)

  % TODO
  % allow threshold to be inferior than, greater than or both

  hdr = spm_vol(sourceImage);
  img = spm_read_vols(hdr);

  roi_hdr = hdr;
  basename = spm_file(roi_hdr.fname, 'basename');
  roi_hdr.fname = spm_file(roi_hdr.fname, 'basename', [basename '-mask']);

  img = img > threshold;

  spm_write_vol(roi_hdr, img);

  roiName = roi_hdr.fname;

end
