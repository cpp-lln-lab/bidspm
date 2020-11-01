% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function deleteResidualImages(ffxDir)
  delete(fullfile(ffxDir, 'Res_*.nii'));
end
