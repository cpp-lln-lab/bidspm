function opt = set_spm_2_bids_defaults(opt)
  %
  % set default map for renaming for cpp_bids
  %
  % USAGE::
  %
  %   opt = set_spm_2_bids_defaults(opt)
  %
  % Further renaming mapping can then be added, changed or removed
  % through the ``opt.spm_2_bids object``.
  %
  % (C) Copyright 2021 CPP_SPM developers

  % TODO update entities normalization to reflect the resolution of each output image
  % TODO stc might not be in individual space (as in not in T1w space)
  % TODO write and update json content
  % TODO renaming of functional mask

  % this conversion could be into desc-preproc
  %   usub-01_task-facerepetition_space-individual_desc-stc_bold.nii -->
  %     sub-01_task-facerepetition_space-individual_desc-realignUnwarp_bold.nii

  map = Mapping();
  map = map.default();

  if ~isempty(opt.fwhm.func) && opt.fwhm.func > 0
    map.cfg.fwhm = opt.fwhm.func;
    fwhm = sprintf('%i', map.cfg.fwhm);
  end

  % add resolution entity when reslicing TPMs
  name_spec = map.cfg.segment.gm;
  name_spec.entities.res = 'bold';
  map = map.add_mapping('prefix', [map.realign 'c1'], 'name_spec', name_spec);

  name_spec = map.cfg.segment.wm;
  name_spec.entities.res = 'bold';
  map = map.add_mapping('prefix', [map.realign 'c2'], 'name_spec', name_spec);

  name_spec = map.cfg.segment.csf;
  name_spec.entities.res = 'bold';
  map = map.add_mapping('prefix', [map.realign 'c3'], 'name_spec', name_spec);

  % when there is the FXHM after smoothing prefix
  prefix = {[map.smooth, fwhm, map.norm], ...
            [map.smooth, fwhm, map.norm, map.unwarp, map.stc], ...
            [map.smooth, fwhm, map.norm, map.realign, map.stc], ...
            [map.smooth, fwhm, map.norm, map.unwarp], ...
            [map.smooth, fwhm, map.norm, map.realign] };
  name_spec = map.cfg.smooth_norm;
  name_spec.entities.desc = ['smth' fwhm];
  map = map.add_mapping('prefix', prefix, 'name_spec', name_spec);

  prefix = {[map.smooth, fwhm, map.unwarp, map.stc], ...
            [map.smooth, fwhm, map.realign, map.stc], ...
            [map.smooth, fwhm, map.unwarp], ...
            [map.smooth, fwhm, map.realign] };
  name_spec = map.cfg.smooth;
  name_spec.entities.desc = ['smth' fwhm];
  map = map.add_mapping('prefix', prefix, 'name_spec', name_spec);

  prefix = [map.smooth, fwhm];
  clear name_spec;
  name_spec.entities.desc = ['smth' fwhm];
  map = map.add_mapping('prefix', prefix, 'name_spec', name_spec);

  prefix = {['std_' map.unwarp, map.stc], ...
            ['std_' map.unwarp]};
  name_spec = map.cfg.mean;
  name_spec.entities.desc = 'std';
  map = map.add_mapping('prefix', prefix, 'name_spec', name_spec);

  % TODO allow add_mapping to accept a whole bids_file structure
  prefix = map.bias_cor;
  suffix = 'T1w';
  ext = '.nii';
  entities = struct('desc', 'skullstripped');
  name_spec = map.cfg.segment.bias_corrected;
  name_spec.entities.desc = 'preproc';
  map = map.add_mapping('prefix', prefix, ...
                        'suffix', suffix, ...
                        'ext', ext, ...
                        'entities', entities, ...
                        'name_spec', name_spec);

  prefix = map.bias_cor;
  suffix = 'mask';
  ext = '.nii';
  entities = struct('label', 'brain');
  name_spec = map.cfg.segment.bias_corrected;
  name_spec.entities = struct('label', 'brain', ...
                              'desc', '');
  map = map.add_mapping('prefix', prefix, ...
                        'suffix', suffix, ...
                        'ext', ext, ...
                        'entities', entities, ...
                        'name_spec', name_spec);

  prefix = 'c1';
  ext = '.surf.gii';
  suffix = 'T1w';
  entities = '*';
  clear name_spec;
  name_spec.ext = '.gii';
  name_spec.entities = struct('desc', 'pialsurf');
  map = map.add_mapping('prefix', prefix, ...
                        'suffix', suffix, ...
                        'ext', ext, ...
                        'entities', entities, ...
                        'name_spec', name_spec);

  prefix = map.norm;
  suffix = 'T1w';
  ext = '.nii';
  entities = struct('desc', 'skullstripped');
  name_spec = map.cfg.segment.bias_corrected;
  name_spec.entities.res = 'r1pt0';
  name_spec.entities.desc = 'preproc';
  map = map.add_mapping('prefix', prefix, ...
                        'suffix', suffix, ...
                        'ext', ext, ...
                        'entities', entities, ...
                        'name_spec', name_spec);

  prefix = [map.norm map.bias_cor];
  suffix = 'T1w';
  ext = '.nii';
  entities = struct('desc', 'skullstripped');
  name_spec = map.cfg.preproc_norm;
  name_spec.entities.res = 'r1pt0';
  map = map.add_mapping('prefix', prefix, ...
                        'suffix', suffix, ...
                        'ext', ext, ...
                        'entities', entities, ...
                        'name_spec', name_spec);

  %% overwrite defaults

  % change defaults for TPM normalisation
  for i = 1:3
    idx = map.find_mapping('prefix', sprintf('%sc%i', map.norm, i));
    map.mapping(idx).name_spec.entities.res = 'bold';
  end

  idx = map.find_mapping('prefix', [map.norm map.bias_cor]);
  map.mapping(idx).name_spec.entities.res = 'r1pt0';
  map.mapping(idx).name_spec.entities.desc = '';

  idx = map.find_mapping('prefix', map.unwarp);
  map.mapping(idx).name_spec.entities.desc = 'preproc';

  idx = map.find_mapping('prefix', [map.unwarp map.stc]);
  map.mapping(idx).name_spec.entities.desc = 'preproc';

  % linearise map
  map = map.flatten_mapping();

  opt.spm_2_bids = map;

end
