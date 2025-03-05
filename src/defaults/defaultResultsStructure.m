function result  = defaultResultsStructure()
  %

  % (C) Copyright 2019 bidspm developers

  result = defaultContrastsStructure;

  result.png = true();

  result.csv = true();
  result.atlas = 'Neuromorphometrics';

  result.threshSpm = false();

  result.binary = false();

  result.montage = struct('do', false(), ...
                          'slices', [], ...
                          'orientation', 'axial', ...
                          'background',  fullfile(spm('dir'), ...
                                                  'canonical', ...
                                                  'avg152T1.nii'));

  result.nidm = true();

  % transparent plot
  layers = struct('color', struct('file', fullfile(spm('dir'), 'canonical', 'avg152T1.nii'), ...
                                  'range', [0 1], ...
                                  'map', gray(256)));

  color_map_folder = fullfile(fileparts(which('map_luminance')), '..', 'mat_maps');
  load(fullfile(color_map_folder, 'diverging_bwr_iso.mat'));

  layers(2) = struct('color', struct('file', [], ... % con image
                                     'map', diverging_bwr, ...
                                     'range', [-4 4]), ...
                     'label', '\beta_{listening} - \beta_{baseline} (a.u.)', ...
                     'opacity', struct('file', [], ... % spmT image
                                       'range', [2 3], ...
                                       'label', '| t |'));

  layers(3) = struct('color', struct('file', [], ... % spmT mask thresholded at 0.05 FWD
                                     'map', [0 0 0], ...
                                     'line_width', 2));

  %% Settings
  settings = sd_config_settings('init');

  % we reuse the details for the SPM montage
  settings.slice.orientation = opt.results(1).montage.orientation;
  settings.slice.disp_slices = -50:10:50;
  settings.fig_specs.n.slice_column = 4;
  settings.fig_specs.title = [];

end
