function opt = get_option_stats(level)
  %
  % returns options chosen to run statistical analysis
  %
  % opt = get_option_preprocess()
  %
  % (C) Copyright 2019 CPP_SPM developers

  if nargin < 1
    level = 'subject';
  end

  % Contrasts.Name has to match one of the contrast defined in the model json file
  if strcmp(level, 'subject')

    opt.results.nodeName = 'subject_level';
    opt.results.name = {'VisMot', 'VisStat', 'VisMot_gt_VisStat'};
    opt.results.png = true();
    opt.results.csv = true();
    opt.results.montage.do = true();
    opt.results.montage.slices = -4:2:16;
    opt.results.montage.orientation = 'axial';
    opt.results.montage.background = struct('suffix', 'T1w', ...
                                            'desc', 'preproc', ...
                                            'modality', 'anat');

  elseif strcmp(level, 'dataset')
    opt.results = struct('nodeName',  'dataset_level', ...
                         'name', {{'VisMot_gt_VisStat'}}, ...
                         'Mask', false, ...
                         'MC', 'none', ...
                         'p', 0.05, ...
                         'k', 10, ...
                         'NIDM', true);
  end

end
