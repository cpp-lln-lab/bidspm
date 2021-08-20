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

  map = Mapping();
  map = map.default();

  if ~isempty(opt.fwhm.func) && opt.fwhm.func > 0
    map.cfg.fwhm = opt.fwhm.func;
    fwhm = sprintf('%i', map.cfg.fwhm);
  end

  mapping = map.mapping;

  findIdx = @(x) strcmp(x, {mapping.prefix}');

  % add resolution entity when reslicing TPMs
  mapping(end + 1).prefix = {[map.realign 'c1']};
  mapping(end).name_spec = map.cfg.segment.gm;
  mapping(end).name_spec.entities.res = 'bold';

  mapping(end + 1).prefix = {[map.realign 'c2']};
  mapping(end).name_spec = map.cfg.segment.wm;
  mapping(end).name_spec.entities.res = 'bold';

  mapping(end + 1).prefix = {[map.realign 'c3']};
  mapping(end).name_spec = map.cfg.segment.csf;
  mapping(end).name_spec.entities.res = 'bold';

  % when there is the FXHM after smoothing prefix
  mapping(end + 1).prefix = {[map.smooth, fwhm, map.norm], ...
                             [map.smooth, fwhm, map.norm, map.unwarp, map.stc], ...
                             [map.smooth, fwhm, map.norm, map.realign, map.stc], ...
                             [map.smooth, fwhm, map.norm, map.unwarp], ...
                             [map.smooth, fwhm, map.norm, map.realign] };
  mapping(end).name_spec = map.cfg.smooth_norm;
  mapping(end).name_spec.entities.desc = ['smth' fwhm];

  mapping(end + 1).prefix = {[map.smooth, fwhm, map.unwarp, map.stc], ...
                             [map.smooth, fwhm, map.realign, map.stc], ...
                             [map.smooth, fwhm, map.unwarp], ...
                             [map.smooth, fwhm, map.realign] };
  mapping(end).name_spec = map.cfg.smooth;
  mapping(end).name_spec.entities.desc = ['smth' fwhm];

  mapping(end + 1).prefix = {[map.smooth, fwhm] };
  mapping(end).name_spec.entities.desc = ['smth' fwhm];

  %
  mapping(end + 1).prefix = {['std_' map.unwarp, map.stc], ...
                             ['std_' map.unwarp]};
  mapping(end).name_spec = map.cfg.mean;
  mapping(end).name_spec.entities.desc = 'std';

  mapping(end + 1).prefix = {map.bias_cor};
  mapping(end).suffix = 'T1w';
  mapping(end).ext = '.nii';
  mapping(end).entities = struct('desc', 'skullstripped');
  mapping(end).name_spec = map.cfg.segment.bias_corrected;
  mapping(end).name_spec.entities.desc = 'preproc';

  mapping(end + 1).prefix = {map.bias_cor};
  mapping(end).suffix = 'mask';
  mapping(end).ext = '.nii';
  mapping(end).entities = struct('label', 'brain');
  mapping(end).name_spec = map.cfg.segment.bias_corrected;
  mapping(end).name_spec.entities = struct('label', 'brain', ...
                                           'desc', '');

  mapping(end + 1).prefix = 'c1';
  mapping(end).ext = '.surf.gii';
  mapping(end).suffix = 'T1w';
  mapping(end).entities = '*';
  mapping(end).name_spec.ext = '.gii';
  mapping(end).name_spec.entities = struct('desc', 'pialsurf');

  mapping(end + 1).prefix = {map.norm};
  mapping(end).suffix = 'T1w';
  mapping(end).ext = '.nii';
  mapping(end).entities = struct('desc', 'skullstripped');
  mapping(end).name_spec = map.cfg.segment.bias_corrected;
  mapping(end).name_spec.entities.res = 'hi';
  mapping(end).name_spec.entities.desc = 'preproc';

  %% overwrite defaults
  % change defaults for TPM normalisation
  for i = 1:3
    idx = findIdx(sprintf('%sc%i', map.norm, i));
    mapping(idx).name_spec.entities.res = 'bold';
  end

  idx = findIdx('rp_');
  mapping(idx) = [];

  idx = strcmp(['rp_' map.stc], {mapping.prefix}');
  mapping(idx) = [];

  idx = strcmp([map.norm map.bias_cor], {mapping.prefix}');
  mapping(idx).name_spec.entities.res = 'hi';
  mapping(idx).name_spec.entities.desc = '';

  idx = findIdx(map.unwarp);
  mapping(idx).name_spec.entities.desc = 'preproc';

  idx = strcmp([map.unwarp map.stc], {mapping.prefix}');
  mapping(idx).name_spec.entities.desc = 'preproc';

  mapping(end + 1).prefix = [map.norm map.bias_cor];
  mapping(end).suffix = 'T1w';
  mapping(end).ext = '.nii';
  mapping(end).entities = struct('desc', 'skullstripped');
  mapping(end).name_spec = map.cfg.preproc_norm;
  mapping(end).name_spec.entities.res = 'hi';

  % linearise mapping
  map.mapping = mapping;
  map = map.flatten_mapping();

  opt.spm_2_bids = map;

end
