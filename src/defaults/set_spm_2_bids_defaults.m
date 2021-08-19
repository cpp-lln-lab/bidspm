function opt = set_spm_2_bids_defaults(opt)
  %
  % set default mapping for renaming for cpp_bids
  %
  % USAGE::
  %
  %  opt = set_spm_2_bids_defaults(opt)
  %
  % (C) Copyright 2021 CPP_SPM developers

  % TODO update entities normalization to reflect the resolution of each output image

  % this conversion could be into desc-preproc
  %   usub-01_task-facerepetition_space-individual_desc-stc_bold.nii -->
  %     sub-01_task-facerepetition_space-individual_desc-realignUnwarp_bold.nii

  % TODO stc might not be in individual space (as in not in T1w space)

  % TODO write and update json content

  % TODO refactor this:
  %  - use spm prefixes instead of hard coding
  %  - probably need to turn mapping into an object with dedicated methods

  % TODO renaming of functional mask

  tmp = check_cfg();
  opt.spm_2_bids = tmp.spm_2_bids;

  if ~isempty(opt.fwhm.func) && opt.fwhm.func > 0
    opt.spm_2_bids.fwhm = opt.fwhm.func;
    fwhm = sprintf('%i', opt.spm_2_bids.fwhm);
  end

  pfx = get_spm_prefix_list();

  mapping = opt.spm_2_bids.mapping;

  findIdx = @(x) strcmp(x, {mapping.prefix}');

  % add resolution entity when reslicing TPMs
  mapping(end + 1).prefix = {[pfx.realign 'c1']};
  mapping(end).name_spec = opt.spm_2_bids.segment.gm;
  mapping(end).name_spec.entities.res = 'bold';

  mapping(end + 1).prefix = {[pfx.realign 'c2']};
  mapping(end).name_spec = opt.spm_2_bids.segment.wm;
  mapping(end).name_spec.entities.res = 'bold';

  mapping(end + 1).prefix = {[pfx.realign 'c3']};
  mapping(end).name_spec = opt.spm_2_bids.segment.csf;
  mapping(end).name_spec.entities.res = 'bold';

  % when there is the FXHM after smoothing prefix
  mapping(end + 1).prefix = {[pfx.smooth, fwhm, pfx.norm], ...
                             [pfx.smooth, fwhm, pfx.norm, pfx.unwarp, pfx.stc], ...
                             [pfx.smooth, fwhm, pfx.norm, pfx.realign, pfx.stc], ...
                             [pfx.smooth, fwhm, pfx.norm, pfx.unwarp], ...
                             [pfx.smooth, fwhm, pfx.norm, pfx.realign] };
  mapping(end).name_spec = opt.spm_2_bids.smooth_norm;
  mapping(end).name_spec.entities.desc = ['smth' fwhm];

  mapping(end + 1).prefix = {[pfx.smooth, fwhm, pfx.unwarp, pfx.stc], ...
                             [pfx.smooth, fwhm, pfx.realign, pfx.stc], ...
                             [pfx.smooth, fwhm, pfx.unwarp], ...
                             [pfx.smooth, fwhm, pfx.realign] };
  mapping(end).name_spec = opt.spm_2_bids.smooth;
  mapping(end).name_spec.entities.desc = ['smth' fwhm];

  mapping(end + 1).prefix = {[pfx.smooth, fwhm] };
  mapping(end).name_spec.entities.desc = ['smth' fwhm];

  %
  mapping(end + 1).prefix = {['std_' pfx.unwarp, pfx.stc], ...
                             ['std_' pfx.unwarp]};
  mapping(end).name_spec = opt.spm_2_bids.mean;
  mapping(end).name_spec.entities.desc = 'std';

  mapping(end + 1).prefix = {pfx.bias_cor};
  mapping(end).suffix = 'T1w';
  mapping(end).ext = '.nii';
  mapping(end).entities = struct('desc', 'skullstripped');
  mapping(end).name_spec = opt.spm_2_bids.segment.bias_corrected;
  mapping(end).name_spec.entities.desc = 'preproc';

  mapping(end + 1).prefix = {pfx.bias_cor};
  mapping(end).suffix = 'mask';
  mapping(end).ext = '.nii';
  mapping(end).entities = struct('label', 'brain');
  mapping(end).name_spec = opt.spm_2_bids.segment.bias_corrected;
  mapping(end).name_spec.entities = struct('label', 'brain', ...
                                           'desc', '');

  mapping(end + 1).prefix = 'c1';
  mapping(end).ext = '.surf.gii';
  mapping(end).suffix = 'T1w';
  mapping(end).entities = '*';
  mapping(end).name_spec.ext = '.gii';
  mapping(end).name_spec.entities = struct('desc', 'pialsurf');

  mapping(end + 1).prefix = {pfx.norm};
  mapping(end).suffix = 'T1w';
  mapping(end).ext = '.nii';
  mapping(end).entities = struct('desc', 'skullstripped');
  mapping(end).name_spec = opt.spm_2_bids.segment.bias_corrected;
  mapping(end).name_spec.entities.res = 'hi';
  mapping(end).name_spec.entities.desc = 'preproc';

  %% overwrite defaults
  % change defaults for TPM normalisation
  for i = 1:3
    idx = findIdx(sprintf('%sc%i', pfx.norm, i));
    mapping(idx).name_spec.entities.res = 'bold';
  end

  idx = findIdx('rp_');
  mapping(idx) = [];

  idx = strcmp(['rp_' pfx.stc], {mapping.prefix}');
  mapping(idx) = [];

  idx = strcmp([pfx.norm pfx.bias_cor], {mapping.prefix}');
  mapping(idx).name_spec.entities.res = 'hi';
  mapping(idx).name_spec.entities.desc = '';

  idx = findIdx(pfx.unwarp);
  mapping(idx).name_spec.entities.desc = 'preproc';

  idx = strcmp([pfx.unwarp pfx.stc], {mapping.prefix}');
  mapping(idx).name_spec.entities.desc = 'preproc';

  mapping(end + 1).prefix = [pfx.norm pfx.bias_cor];
  mapping(end).suffix = 'T1w';
  mapping(end).ext = '.nii';
  mapping(end).entities = struct('desc', 'skullstripped');
  mapping(end).name_spec = opt.spm_2_bids.preproc_norm;
  mapping(end).name_spec.entities.res = 'hi';

  % linearise mapping
  opt.spm_2_bids.mapping = flatten_mapping(mapping);

end
