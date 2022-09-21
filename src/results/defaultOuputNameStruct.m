function outputName = defaultOuputNameStruct(opt, result)
  %
  %
  % USAGE::
  %
  %   outputName = defaultOuputNameStruct(opt, result)
  %
  % :param opt: Options chosen for the analysis.
  %             See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt:  structure
  %
  % :param result:
  % :type  result: structure
  %
  % :returns: - :outputName: (structure)
  %
  % See also: setBatchSubjectLevelResults, bidsResults
  %

  % (C) Copyright 2021 bidspm developers

  outputName = struct('suffix', 'spmT', ...
                      'ext', '.nii', ...
                      'use_schema', 'false', ...
                      'entities', struct('sub', '', ...
                                         'task', strjoin(opt.taskName, ''), ...
                                         'space', result.space, ...
                                         'desc', '', ...
                                         'label', sprintf('%04.0f', result.contrastNb), ...
                                         'p', '', ...
                                         'k', '', ...
                                         'MC', ''));

end
