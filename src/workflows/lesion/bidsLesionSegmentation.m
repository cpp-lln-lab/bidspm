function bidsLesionSegmentation(opt)
  %
  % Use the ALI toolbox to perform segmentation to detect lesions of anatomical image.
  %
  % Requires the ALI toolbox: https://doi.org/10.3389/fnins.2013.00241
  %
  % USAGE::
  %
  %  bidsLesionSegmentation(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Segmentation will be performed using the information provided in the BIDS data set.
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  opt.pipeline.type = 'preproc';

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'lesion segmentation');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = {};
    matlabbatch = setBatchLesionSegmentation(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, 'LesionSegmentation', opt, subLabel);

    % copyFigures(BIDS, opt, subLabel);

  end

  opt = setRenamingConfig(opt);
  bidsRename(opt);

end

function opt = setRenamingConfig(opt)

  opt = set_spm_2_bids_defaults(opt);
  map = opt.spm_2_bids;

  name_spec = map.cfg.segment.gm;
  name_spec.entities.res = 'r2pt0';
  map = map.add_mapping('prefix', [map.realign 'c1'], ...
                        'name_spec', name_spec);

  name_spec = map.cfg.segment.wm;
  name_spec.entities.res = 'r2pt0';
  map = map.add_mapping('prefix', [map.realign 'c2'], ...
                        'name_spec', name_spec);

  name_spec = map.cfg.segment.csf;
  name_spec.entities.res = 'r2pt0';
  map = map.add_mapping('prefix', [map.realign 'c3'], ...
                        'name_spec', name_spec);

  name_spec = map.cfg.segment.gm;
  name_spec.entities.label = 'PRIOR';
  name_spec.entities.res = 'r2pt0';
  map = map.add_mapping('prefix', [map.realign 'c4'], ...
                        'name_spec', name_spec);

  name_spec = map.cfg.segment.gm_norm;
  name_spec.entities.label = 'PRIOR';
  name_spec.entities.res = 'r2pt0';
  map = map.add_mapping('prefix', [map.norm 'c4'], ...
                        'name_spec', name_spec);

  % 4th class prior next iteration
  name_spec = map.cfg.segment.gm_norm;
  name_spec.entities.label = 'PRIOR';
  name_spec.entities.res = 'r1pt5';
  name_spec.entities.desc = 'nextIte';
  map = map.add_mapping('prefix', [map.norm 'c4prior1'], ...
                        'name_spec', name_spec);

  % 4th class at previous iteration
  name_spec = map.cfg.segment.gm_norm;
  name_spec.entities.label = 'PRIOR';
  name_spec.entities.res = 'r1pt5';
  name_spec.entities.desc = 'prevIte';
  map = map.add_mapping('prefix', [map.norm 'c4previous1'], ...
                        'name_spec', name_spec);

  name_spec = map.cfg.segment.gm_norm;
  name_spec.entities.res = 'r2pt0';
  name_spec.entities.desc = 'smth8';
  map = map.add_mapping('prefix', [map.smooth map.norm 'c1'], ...
                        'name_spec', name_spec);

  name_spec = map.cfg.segment.wm_norm;
  name_spec.entities.res = 'r2pt0';
  name_spec.entities.desc = 'smth8';
  map = map.add_mapping('prefix', [map.smooth map.norm 'c2'], ...
                        'name_spec', name_spec);

  opt.spm_2_bids = map.flatten_mapping();

end
