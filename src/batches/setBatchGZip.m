% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchGZip(unzippedNiifiles, keepUnzippedNii)
  %
  % Set the batch for GZip the 4D volumes
  %
  % USAGE::
  %
  %   matlabbatch = setBatchGZip(unzippedNiifiles, keepUnzippedNii)
  %
  % :param unzippedNiifiles: List of volumes to be gzipped
  % :type unzippedNiifiles: array
  % :param keepUnzippedNii: Boolean to decide to delete the unzipped files
  % :type keepUnzippedNii: boolean
  %
  % :returns: - :matlabbatch: (struct) The matlabbath ready to run the spm job

  matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gzip_files.files = unzippedNiifiles;
  matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gzip_files.outdir = {''};
  matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gzip_files.keep = keepUnzippedNii;

end
