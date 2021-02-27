% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchGZip(matlabbatch, unzippedNiifiles, keepUnzippedNii)
  %
  % Set the batch for GZip the 4D volumes
  %
  % USAGE::
  %
  %   matlabbatch = setBatchGZip(matlabbatch, unzippedNiifiles, keepUnzippedNii = false)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param unzippedNiifiles: List of volumes to be gzipped
  % :type unzippedNiifiles: array
  % :param keepUnzippedNii: Boolean to decide to delete the unzipped files
  % :type keepUnzippedNii: boolean
  %
  % :returns: - :matlabbatch: (struct) The matlabbath ready to run the spm job

  if nargin < 3 || isempty(keepUnzippedNii)
    % delete the original unzipped .nii
    keepUnzippedNii = false;
  end

  printBatchName('zipping');

  matlabbatch{end + 1}.cfg_basicio.file_dir.file_ops.cfg_gzip_files.files = unzippedNiifiles;
  matlabbatch{end}.cfg_basicio.file_dir.file_ops.cfg_gzip_files.outdir = {''};
  matlabbatch{end}.cfg_basicio.file_dir.file_ops.cfg_gzip_files.keep = keepUnzippedNii;

end
