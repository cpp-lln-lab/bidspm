function defaults = rsHRF_my_defaults()
  %
  %  USAGE::
  %
  %    defaults = rsHRF_my_defaults()
  %
  % Set defaults for the rsHRF toolbox
  %
  % (C) Copyright 2020 bidspm developers

  vox_rsHRF.Denoising.generic = cell(1, 0);
  vox_rsHRF.Denoising.Detrend = 0;
  vox_rsHRF.Denoising.BPF = {};
  vox_rsHRF.Denoising.Despiking = 0;
  vox_rsHRF.Denoising.which1st = 3;

  vox_rsHRF.HRFE.hrfm = 2;
  vox_rsHRF.HRFE.hrflen = 32;
  vox_rsHRF.HRFE.num_basis = NaN;
  vox_rsHRF.HRFE.mdelay = [4 8];
  vox_rsHRF.HRFE.cvi = 0;
  vox_rsHRF.HRFE.fmri_t = 1;
  vox_rsHRF.HRFE.fmri_t0 = 1;
  vox_rsHRF.HRFE.thr = 1;
  vox_rsHRF.HRFE.localK = 2;
  vox_rsHRF.HRFE.tmask = NaN;
  vox_rsHRF.HRFE.hrfdeconv = 1;

  vox_rsHRF.rmoutlier = 0;

  vox_rsHRF.connectivity = cell(1, 0);

  vox_rsHRF.savedata.deconv_save = 0;
  vox_rsHRF.savedata.hrfmat_save = 1;
  vox_rsHRF.savedata.hrfnii_save = 1;
  vox_rsHRF.savedata.job_save = 0;

  vox_rsHRF.prefix = 'deconv_';

  defaults.toolbox.rsHRF.vox_rsHRF = vox_rsHRF;

end
