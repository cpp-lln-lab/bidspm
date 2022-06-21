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

  args = inputParser;

  defaultDesc = '';
  defaultSubLabel = '';

  addRequired(args, 'opt', @isstruct);
  addOptional(args, 'desc', defaultDesc, @ischar);
  addOptional(args, 'subLabel', defaultSubLabel, @ischar);

  parse(args, varargin{:});

  nameStructure = struct( ...
                         'suffix', 'designmatrix', ...
                         'ext', '.png', ...
                         'entities', struct('sub', args.Results.subLabel, ...
                                            'task', strjoin(args.Results.opt.taskName, ''), ...
                                            'space', args.Results.opt.space));
  nameStructure.entities.desc = args.Results.desc;
  bidsFile = bids.File(nameStructure);
  filename = bidsFile.filename;

end
