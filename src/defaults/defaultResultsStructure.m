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

end
