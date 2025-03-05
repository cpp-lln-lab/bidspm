% (C) Copyright 2020 bidspm developers

function test_suite = test_defaultResultsStructure %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_defaultResultsStructure_basic()

  results  = defaultResultsStructure();

  expected.nodeName =  '';

  expected.name = {''};

  expected.useMask = false();
  expected.MC = 'FWE';
  expected.p = 0.05;
  expected.k = 0;

  expected.png = true();

  expected.csv = true();
  expected.atlas = 'Neuromorphometrics';

  expected.threshSpm = false();

  expected.binary = false();

  expected.montage.do = false();
  expected.montage.slices = [];
  expected.montage.orientation = 'axial';
  expected.montage.background = fullfile(spm('dir'), 'canonical', 'avg152T1.nii');

  expected.nidm = true();
  
  
  layers{1} = struct('color', struct('file', expected.montage.background, ...
                                     'range', [0 1], ...
                                     'map', gray(256)));

  layers{2} = struct('color', struct('file', [], ... % con image
                                     'map', 'diverging_bwr_iso', ...
                                     'range', [-4 4]), ...
                     'label', '\beta_{listening} - \beta_{baseline} (a.u.)', ...
                     'opacity', struct('file', [], ... % spmT image
                                       'range', [2 3], ...
                                       'label', '| t |'));

  layers{3} = struct('color', struct('file', [], ... % spmT mask thresholded at 0.05 FWD
                                     'map', [0 0 0], ...
                                     'line_width', 2));

  expected.sdConfig.layers = layers;

  settings = sd_config_settings('init');
  
  settings = sd_config_settings('init');

  settings.slice.orientation = expected.montage.orientation;
  settings.slice.disp_slices = -50:10:50;
  settings.fig_specs.n.slice_column = 4;
  settings.fig_specs.title = [];

  expected.sdConfig.settings = settings;

  assertEqual(results, expected);

end
