function matlabbatch = setBatchLesionOverlapMap(matlabbatch, BIDS, opt, subLabel)
  %
  % Creates a batch for the lesion overlap map
  %
  % Requires the ALI toolbox: https://doi.org/10.3389/fnins.2013.00241
  %
  % USAGE::
  %
  %   matlabbatch = setBatchLesionOverlapMap(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch: list of SPM batches
  % :type matlabbatch: structure
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2021 CPP_SPM developers

  printBatchName('Lesion overlap map');

  % Specify lesion overlap map
  matlabbatch{1}.spm.tools.ali.lesion_overlap.lom = '<UNDEFINED>';

end
