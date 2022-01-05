function matlabbatch = setBatchCoregistration(varargin)
  %
  % Set the batch for coregistering the source images into the reference image
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
  % :param other: Other images to apply the coregistration to
  % :type other: cell string
  %
  % :returns: - :matlabbatch: (structure) The matlabbatch ready to run the spm job
  %
  % (C) Copyright 2020 CPP_SPM developers

  default_other = {''};

  isFile = @(x) exist(x, 'file') == 2;

  p = inputParser;

  addRequired(p, 'matlabbatch', @iscell);
  addRequired(p, 'ref', isFile);
  addRequired(p, 'src', isFile);
  addOptional(p, 'other', default_other, @iscell);

  parse(p, varargin{:});

  matlabbatch = p.Results.matlabbatch;
  ref = p.Results.ref;
  src = p.Results.src;
  other = p.Results.other;

  printBatchName('coregistration', opt);

  matlabbatch{end + 1}.spm.spatial.coreg.estimate.ref = { ref };
  matlabbatch{end}.spm.spatial.coreg.estimate.source = { src };
  matlabbatch{end}.spm.spatial.coreg.estimate.other = other;

end
