% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function deleteResidualImages(ffxDir)
  delete(fullfile(ffxDir, 'Res_*.nii'));
end
