function matlabbatch = setBatchGroupLevelResults(varargin)
  %
  %
  % USAGE::
  %
  %   matlabbatch = setBatchGroupLevelResults(matlabbatch, opt, result)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :param result:
  % :type result: structure
  %
  % :return: matlabbatch
  % :rtype: structure

  % (C) Copyright 2019 bidspm developers

  [matlabbatch, opt, result] = deal(varargin{:});

  load(fullfile(result.dir, 'SPM.mat'));
  result.nbSubj = SPM.nscan;

  result.label = 'group';

  matlabbatch = setBatchResults(matlabbatch, opt, result);

end
