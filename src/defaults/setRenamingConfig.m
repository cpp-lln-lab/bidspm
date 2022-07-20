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

  switch lower(workflowName)

    case 'lesionsegmentation'

      opt.spm_2_bids = Mapping;

      opt = set_spm_2_bids_defaults(opt);
      map = opt.spm_2_bids;

      nameSpec = map.cfg.segment.gm;
      nameSpec.entities.res = 'r2pt0';
      prefix =  [map.realign 'c1'];
      map = replaceMapping(map, prefix, nameSpec);

      nameSpec = map.cfg.segment.wm;
      nameSpec.entities.res = 'r2pt0';
      prefix =  [map.realign 'c2'];
      map = replaceMapping(map, prefix, nameSpec);

      nameSpec = map.cfg.segment.csf;
      nameSpec.entities.res = 'r2pt0';
      prefix =  [map.realign 'c3'];
      map = replaceMapping(map, prefix, nameSpec);

      nameSpec = map.cfg.segment.gm;
      nameSpec.entities.label = 'PRIOR';
      nameSpec.entities.res = 'r2pt0';
      idx = map.find_mapping('prefix', [map.realign 'c4']);
      map = map.rm_mapping(idx);
      map = map.add_mapping('prefix', [map.realign 'c4'], ...
                            'name_spec', nameSpec);

      nameSpec = map.cfg.segment.gm_norm;
      nameSpec.entities.label = 'PRIOR';
      nameSpec.entities.res = 'r2pt0';
      idx = map.find_mapping('prefix', [map.norm 'c4']);
      map = map.rm_mapping(idx);
      map = map.add_mapping('prefix', [map.norm 'c4'], ...
                            'name_spec', nameSpec);

      % 4th class prior next iteration
      nameSpec = map.cfg.segment.gm_norm;
      nameSpec.entities.label = 'PRIOR';
      nameSpec.entities.res = 'r1pt5';
      nameSpec.entities.desc = 'nextIte';
      map = map.add_mapping('prefix', [map.norm 'c4prior1'], ...
                            'name_spec', nameSpec);

      % 4th class at previous iteration
      nameSpec = map.cfg.segment.gm_norm;
      nameSpec.entities.label = 'PRIOR';
      nameSpec.entities.res = 'r1pt5';
      nameSpec.entities.desc = 'prevIte';
      map = map.add_mapping('prefix', [map.norm 'c4previous1'], ...
                            'name_spec', nameSpec);

      nameSpec = map.cfg.segment.gm_norm;
      nameSpec.entities.res = 'r2pt0';
      nameSpec.entities.desc = 'smth8';
      prefix =  [map.smooth map.norm 'c1'];
      map = replaceMapping(map, prefix, nameSpec);

      nameSpec = map.cfg.segment.wm_norm;
      nameSpec.entities.res = 'r2pt0';
      nameSpec.entities.desc = 'smth8';
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
