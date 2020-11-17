% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchCoregistration(matlabbatch, ref, src, other)
  %
  % Set the batch for corregistering the source images into the reference image???
  %
  % USAGE::
  %
  %   matlabbatch = setBatchCoregistration(matlabbatch, ref, src, other)
  %
  % :param matlabbatch: list of SPM batches
  % :type matlabbatch: structure
  % :param ref: Reference image
  % :type ref: string
  % :param src: Source image
  % :type src: string
  % :param other: ?
  % :type other: cell string
  %
  % :returns: - :matlabbatch: (structure) The matlabbatch ready to run the spm job
  %
  % matlabbatch = setBatchCoregistrationGeneral(matlabbatch, ref, src, other)
  %

  printBatchName('coregistration');

  matlabbatch{end + 1}.spm.spatial.coreg.estimate.ref = { ref };
  matlabbatch{end}.spm.spatial.coreg.estimate.source = { src };
  matlabbatch{end}.spm.spatial.coreg.estimate.other = other;

end
