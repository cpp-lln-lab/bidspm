function matlabbatch = setBatchGroupLevelResults(varargin)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchGroupLevelResults(matlabbatch, opt, result)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param opt:
  % :type opt: structure
  % :param result:
  % :type result: structure
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2019 CPP_SPM developers

  [matlabbatch, opt, result] = deal(varargin{:});

  result.dir = fullfile(getRFXdir(opt), result.Contrasts.Name);

  load(fullfile(result.dir, 'SPM.mat'));
  result.nbSubj = SPM.nscan;

  result.contrastNb = 1;

  result.label = 'group';

  result.outputNameStructure = defaultOuputNameStruct(opt, result);

  matlabbatch = setBatchResults(matlabbatch, result);

end
