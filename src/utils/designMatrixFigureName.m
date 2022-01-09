function filename = designMatrixFigureName(varargin)
  %
  % USAGE::
  %
  %   filename = designMatrixFigureName(opt, desc, subLabel)
  %
  % :param opt:
  % :type opt: structure
  % :param desc: optional argument. default: ``''``
  % :type desc: string
  % :param subLabel: optional argument. default: ``''``
  % :type subLabel: string
  %
  % :returns: - :filename: (string)
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  % The code goes below

  p = inputParser;

  default_desc = '';
  default_subLabel = '';

  addRequired(p, 'opt', @isstruct);
  addOptional(p, 'desc', default_desc, @ischar);
  addOptional(p, 'subLabel', default_subLabel, @ischar);

  parse(p, varargin{:});

  nameStructure = struct( ...
                         'suffix', 'designmatrix', ...
                         'ext', '.png', ...
                         'entities', struct( ...
                                            'sub', p.Results.subLabel, ...
                                            'task', strjoin(p.Results.opt.taskName, ''), ...
                                            'space', p.Results.opt.space));
  nameStructure.entities.desc = p.Results.desc;
  bidsFile = bids.File(nameStructure);
  filename = bidsFile.filename;

end
