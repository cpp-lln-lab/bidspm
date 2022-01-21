function batchFileName = returnBatchFileName(batchType, ext)
  %
  % USAGE::
  %
  %   batchFileName = returnBatchFileName([batchType] [, ext])
  %
  % :param batchType:
  % :type batchType: cell
  % :param ext: optional.
  % :type ext: structure
  %
  % :returns: - :batchFileName: (path)
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  if nargin < 1
    batchType = '';
  end

  if nargin < 2
    ext = '.mat';
  end

  if ~strcmp(batchType, '')
    batchType = ['_' batchType];
  end

  batchFileName = sprintf('batch%s_%s%s', batchType, timeStamp(), ext);

  % matlab scripts cannot have hyphens
  if strcmp(ext, '.m')
    batchFileName = strrep(batchFileName, '-', '_');
  end

end
