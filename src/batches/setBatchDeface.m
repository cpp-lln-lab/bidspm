% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchDeface(anatVolumesList)
  %
  % Set the batch for anatomical defacing
  %
  % USAGE:: 
  %
  %   matlabbatch = setBatchDeface(anatVolumesList)
  %
  % :param anatVolumesList: List of anatomical volumes to be defaced
  % :type anatVolumesList: array
  %
  % :returns: - :matlabbatch: (struct) The matlabbath ready to run the spm job

  matlabbatch{1}.spm.util.deface.images = anatVolumesList;

end