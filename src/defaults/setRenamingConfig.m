function opt = setRenamingConfig(opt, workflowName)
  %
  % set default map for renaming for a specific workflow
  %
  % USAGE::
  %
  %   opt = setRenamingConfig(opt, workflowName)
  %
  %

  % (C) Copyright 2021 bidspm developers

  opt = set_spm_2_bids_defaults(opt);
  map = opt.spm_2_bids;

  switch lower(workflowName)

    case 'spatialprepro'

      if ~opt.realign.useUnwarp
        map = map.add_mapping('prefix', map.realign, ...
                              'name_spec', map.cfg.preproc);

        map = map.add_mapping('prefix', [map.realign 'mean'], ...
                              'name_spec', map.cfg.mean);
      end

    case 'realignreslice'

      map = map.add_mapping('prefix', map.realign, ...
                            'name_spec', map.cfg.preproc);

      map = map.add_mapping('prefix', [map.realign 'mean'], ...
                            'name_spec', map.cfg.mean);

    case 'reslicetpmtofunc'

      name_spec.entities.res = 'bold';
      map = map.add_mapping('prefix', map.realign, ...
                            'name_spec', name_spec);

    case 'lesiondetection'

      nameSpec = struct('prefix', '', 'suffix', 'roi', ...
                        'entities', struct('label', 'lesion'));
      prefix =  'Lesion_binary_';
      map = replaceMapping(map, prefix, nameSpec);

      nameSpec = struct('prefix', '', 'suffix', 'roi', ...
                        'entities', struct('label', 'lesion', ...
                                           'desc', 'contour'));
      prefix =  'Lesion_contour_';
      map = replaceMapping(map, prefix, nameSpec);

      nameSpec = struct('prefix', '', 'suffix', 'roi', ...
                        'entities', struct('label', 'lesion', ...
                                           'desc', 'fuzzy'));
      prefix =  'Lesion_fuzzy_';
      map = replaceMapping(map, prefix, nameSpec);

      nameSpec = struct('prefix', '', 'suffix', 'outliers');
      prefix =  'Outliers_low_';
      map = replaceMapping(map, prefix, nameSpec);

    case 'lesionsegmentation'

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
      nameSpec.entities.res = res;
      idx = map.find_mapping('prefix', [map.norm 'c1']);
      map = map.rm_mapping(idx);
      map = map.add_mapping('prefix', [map.norm 'c1'], ...
                            'name_spec', nameSpec);

      nameSpec = map.cfg.segment.wm_norm;
      nameSpec.entities.res = res;
      idx = map.find_mapping('prefix', [map.norm 'c2']);
      map = map.rm_mapping(idx);
      map = map.add_mapping('prefix', [map.norm 'c2'], ...
                            'name_spec', nameSpec);

      nameSpec = map.cfg.segment.csf_norm;
      nameSpec.entities.res = res;
      idx = map.find_mapping('prefix', [map.norm 'c3']);
      map = map.rm_mapping(idx);
      map = map.add_mapping('prefix', [map.norm 'c3'], ...
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

  map = map.flatten_mapping();

  opt.spm_2_bids = map;

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
