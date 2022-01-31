function matlabbatch = setBatchReorient(varargin)
  %
  % Short batch description
  %
  % USAGE::
  %
  %   matlabbatch = setBatchReorient(matlabbatch, opt, images, reorientMatrix, 'prefix', '')
  %
  % :param matlabbatch: matlabbatch to append to.
  % :type matlabbatch: cell
  %
  % :param opt:
  % :type opt: structure
  %
  % :param images:
  % :type images: cell string
  %
  % :param reorientMatrix:  4 X 4 transformation matric or .mat file containing
  % one in a ``transformationMatrix`` variable
  %
  % :param prefix:
  % :type prefix: string
  %
  %
  % :returns: - :matlabbatch: (cell) The matlabbatch ready to run the spm job
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;

  transformationMatrixOrMatFile = @(x) (isnumeric(x)     &&  all(size(x) == [4, 4])) || ...
    (exist(x, 'file') &&  strcmp(spm_file(x, 'ext'), 'mat'));

  addRequired(p, 'matlabbatch', @iscell);
  addRequired(p, 'opt', @isstruct);
  addRequired(p, 'images', @iscellstr);
  addRequired(p, 'reorientMatrix', transformationMatrixOrMatFile);
  addParameter(p, 'prefix', '', @ischar);

  parse(p, varargin{:});

  matlabbatch = p.Results.matlabbatch;
  opt = p.Results.opt;
  images = p.Results.images;
  reorientMatrix = p.Results.reorientMatrix;
  prefix = p.Results.prefix;

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
