function matlabbatch = setBatchReorient(varargin)
  %
  % Set up a batch to reorient images.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchReorient(matlabbatch, opt, images, reorientMatrix, 'prefix', '')
  %
  % :param matlabbatch: matlabbatch to append to.
  % :type  matlabbatch: cell
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :type  opt:  structure
  %
  % :param images:
  % :type  images: cell string
  %
  % :param reorientMatrix:  4 X 4 transformation matrix or .mat file containing
  %                         a ``transformationMatrix`` variable
  %
  % :param prefix:
  % :type  prefix: char
  %
  %
  % :return: :matlabbatch: (cell) The matlabbatch ready to run the spm job
  %
  %

  % (C) Copyright 2022 bidspm developers

  args = inputParser;

  transformationMatrixOrMatFile = @(x) (isnumeric(x)     &&  all(size(x) == [4, 4])) || ...
    (exist(x, 'file') &&  strcmp(spm_file(x, 'ext'), 'mat'));

  addRequired(args, 'matlabbatch', @iscell);
  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'images', @iscellstr);
  addRequired(args, 'reorientMatrix', transformationMatrixOrMatFile);
  addParameter(args, 'prefix', '', @ischar);

  parse(args, varargin{:});

  matlabbatch = args.Results.matlabbatch;
  opt = args.Results.opt;
  images = args.Results.images;
  reorientMatrix = args.Results.reorientMatrix;
  prefix = args.Results.prefix;

  printBatchName('reorient images', opt);

  reorient.srcfiles = images;

  if isnumeric(reorientMatrix)
    reorient.transform.transM = reorientMatrix;

  elseif exist(reorientMatrix, 'file')
    load(reorientMatrix, 'transformationMatrix');
    reorient.transform.transM = transformationMatrix;

  end
  reorient.prefix = prefix;

  matlabbatch{end + 1}.spm.util.reorient = reorient;

end
