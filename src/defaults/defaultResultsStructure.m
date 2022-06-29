function contrast  = defaultResultsStructure()
  %
  % (C) Copyright 2019 CPP_SPM developers

  contrast = defaultContrastsStructure;

  contrast.png = true();

  contrast.csv = true();

  contrast.threshSpm = false();

  contrast.binary = false();

  contrast.montage = struct('do', false(), ...
                            'slices', [], ...
                            'orientation', 'axial', ...
                            'background',  fullfile(spm('dir'), ...
                                                    'canonical', ...
                                                    'avg152T1.nii'));

  contrast.nidm = true();

end
