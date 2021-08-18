function opt = set_spm_2_bids_defaults(opt)
  %
  % Step 2. Detects lesion abnormalities in anatomical image after segmentation of the image.
  %
  % USAGE::
  %
  %  bidsLesionAbnormalitiesDetection(opt)
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  tmp = check_cfg();
  opt.spm_2_bids = tmp.spm_2_bids;

  if ~isempty(opt.fwhm.func) && opt.fwhm.func > 0
    opt.spm_2_bids.fwhm = opt.fwhm.func;
    fwhm = sprintf('%i', opt.spm_2_bids.fwhm);
  end

  pfx = get_spm_prefix_list();

  mapping = opt.spm_2_bids.mapping;

  findIdx = @(x) strcmp(x, {mapping.prefix}');
  for i = 1:3
    idx = strcmp(sprintf('wc%i', i), {mapping.prefix}');
    mapping(idx).name_spec.entities.res = 'bold';
  end

  opt.spm_2_bids.mapping = flatten_mapping(mapping);

end
