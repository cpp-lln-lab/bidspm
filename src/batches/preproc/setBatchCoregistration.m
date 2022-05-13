function matlabbatch = setBatchCoregistration(varargin)
  %
  % Set the batch for coregistering the source images into the reference image
  %
  % USAGE::
  %
  %   matlabbatch = setBatchCoregistration(matlabbatch, opt, ref, src, other)
  %
  % :param matlabbatch: list of SPM batches
  % :type matlabbatch: structure
  %
  % :param opt: Other images to apply the coregistration to
  % :type opt: cell string
  %
  % :param ref: Reference image
  % :type ref: string
  %
  % :param src: Source image
  % :type src: string
  %
  % :param other: Other images to apply the coregistration to
  % :type other: cell string
  %
  % :returns: - :matlabbatch: (structure) The matlabbatch ready to run the spm job
  %
  %
  % EXAMPLE::
  %
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  defaultOther = {''};

  isFile = @(x) exist(x, 'file') == 2;

  args = inputParser;

  addRequired(args, 'matlabbatch', @iscell);
  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'ref', isFile);
  addRequired(args, 'src', isFile);
  addOptional(args, 'other', defaultOther, @iscell);

  parse(args, varargin{:});

  matlabbatch = args.Results.matlabbatch;
  ref = args.Results.ref;
  src = args.Results.src;
  other = args.Results.other;

  printBatchName('coregistration', args.Results.opt);

  matlabbatch{end + 1}.spm.spatial.coreg.estimate.ref = { ref };
  matlabbatch{end}.spm.spatial.coreg.estimate.source = { src };
  matlabbatch{end}.spm.spatial.coreg.estimate.other = other;

end
