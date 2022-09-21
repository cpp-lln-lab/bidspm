function matlabbatch = setBatchReorient(varargin)
  %
  % Short batch description
  %
  % USAGE::
  %
  %   matlabbatch = setBatchReorient(matlabbatch, opt, images, reorientMatrix, 'prefix', '')
  %
  % :param matlabbatch: matlabbatch to append to.
  % :type  matlabbatch: cell
  %
  % :type  opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %
  % :param images:
  % :type  images: cell string
  %
  % :param reorientMatrix:  4 X 4 transformation matric or .mat file containing
  %                         a ``transformationMatrix`` variable
  %
  % :param prefix:
  % :type  prefix: char
  %
  %
  % :returns: - :matlabbatch: (cell) The matlabbatch ready to run the spm job
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
