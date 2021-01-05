% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function deleteResidualImages(ffxDir)
  %
  % USAGE::
  %
  %   deleteResidualImages(ffxDir)
  %
  % :param ffxDir:
  % :type ffxDir: string
  %

  delete(fullfile(ffxDir, 'Res_*.nii'));
  delete(fullfile(ffxDir, 'res4d.nii*'));

end
