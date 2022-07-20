function opt = setRenamingConfig(opt, workflowName)
  %
  % set default map for renaming for a specific workflow
  %
  % USAGE::
  %
  %   opt = setRenamingConfig(opt, workflowName)
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  opt = set_spm_2_bids_defaults(opt);

  switch lower(workflowName)

    case 'spatialprepro'

      if ~opt.realign.useUnwarp
        opt.spm_2_bids = opt.spm_2_bids.add_mapping('prefix', opt.spm_2_bids.realign, ...
                                                    'name_spec', opt.spm_2_bids.cfg.preproc);

        opt.spm_2_bids = opt.spm_2_bids.add_mapping('prefix', [opt.spm_2_bids.realign 'mean'], ...
                                                    'name_spec', opt.spm_2_bids.cfg.mean);
        opt.spm_2_bids = opt.spm_2_bids.flatten_mapping();
      end

    case 'realignreslice'

      opt.spm_2_bids = opt.spm_2_bids.add_mapping('prefix', opt.spm_2_bids.realign, ...
                                                  'name_spec', opt.spm_2_bids.cfg.preproc);

      opt.spm_2_bids = opt.spm_2_bids.add_mapping('prefix', [opt.spm_2_bids.realign 'mean'], ...
                                                  'name_spec', opt.spm_2_bids.cfg.mean);

    case 'reslicetpmtofunc'

      name_spec.entities.res = 'bold';
      opt.spm_2_bids = opt.spm_2_bids.add_mapping('prefix', opt.spm_2_bids.realign, ...
                                                  'name_spec', name_spec);

    case 'lesionsegmentation'

      map = opt.spm_2_bids;

      res = opt.toolbox.ALI.unified_segmentation.step1vox;
      res = ['r' convertToStr(res)];
      fwhm = opt.toolbox.ALI.unified_segmentation.step1fwhm;

      nameSpec = map.cfg.segment.gm;
      nameSpec.entities.res = res;
      prefix =  [map.realign 'c1'];
      map = replaceMapping(map, prefix, nameSpec);

      nameSpec = map.cfg.segment.wm;
      nameSpec.entities.res = res;
      prefix =  [map.realign 'c2'];
      map = replaceMapping(map, prefix, nameSpec);

      nameSpec = map.cfg.segment.csf;
      nameSpec.entities.res = res;
      prefix =  [map.realign 'c3'];
      map = replaceMapping(map, prefix, nameSpec);

      nameSpec = map.cfg.segment.gm;
      nameSpec.entities.label = 'PRIOR';
      nameSpec.entities.res = res;
      idx = map.find_mapping('prefix', [map.realign 'c4']);
      map = map.rm_mapping(idx);
      map = map.add_mapping('prefix', [map.realign 'c4'], ...
                            'name_spec', nameSpec);

      nameSpec = map.cfg.segment.gm_norm;
      nameSpec.entities.label = 'PRIOR';
      nameSpec.entities.res = res;
      idx = map.find_mapping('prefix', [map.norm 'c4']);
      map = map.rm_mapping(idx);
      map = map.add_mapping('prefix', [map.norm 'c4'], ...
                            'name_spec', nameSpec);

      nbIteration = opt.toolbox.ALI.unified_segmentation.step1niti;
      for i = 1:(nbIteration - 1)
        % 4th class prior next iteration
        nameSpec = map.cfg.segment.gm_norm;
        nameSpec.entities.label = 'PRIOR';
        nameSpec.entities.res = 'r1pt5';
        nameSpec.entities.desc = sprintf('nextIte%i', i);
        map = map.add_mapping('prefix', sprintf('%sc4prior%i', map.norm, i), ...
                              'name_spec', nameSpec);

        % 4th class at previous iteration
        nameSpec = map.cfg.segment.gm_norm;
        nameSpec.entities.label = 'PRIOR';
        nameSpec.entities.res = 'r1pt5';
        nameSpec.entities.desc = sprintf('prevIte%i', i);
        map = map.add_mapping('prefix', sprintf('%sc4previous%i', map.norm, i), ...
                              'name_spec', nameSpec);
      end

      nameSpec = map.cfg.segment.gm_norm;
      nameSpec.entities.res = res;
      nameSpec.entities.desc = ['smth' num2str(fwhm)];
      prefix =  [map.smooth map.norm 'c1'];
      map = replaceMapping(map, prefix, nameSpec);

      nameSpec = map.cfg.segment.wm_norm;
      nameSpec.entities.res = res;
      nameSpec.entities.desc = ['smth' num2str(fwhm)];
      prefix =  [map.smooth map.norm 'c2'];
      map = replaceMapping(map, prefix, nameSpec);

  end

  opt.spm_2_bids = map.flatten_mapping();

end

function map = replaceMapping(map, prefix, nameSpec)
  idx = map.find_mapping('prefix', prefix);
  map = map.rm_mapping(idx);
  map = map.add_mapping('prefix', prefix, ...
                        'name_spec', nameSpec);
end

function out = convertToStr(in)
  out = num2str(in);
  out = strrep(out, '.', 'pt');
end
