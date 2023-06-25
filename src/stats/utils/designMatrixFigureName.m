function filename = designMatrixFigureName(varargin)
  %
  % USAGE::
  %
  %   filename = designMatrixFigureName(opt, desc, subLabel)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  % :param desc: optional argument. default: ``''``
  % :type desc: char
  % :param subLabel: optional argument. default: ``''``
  % :type subLabel: char
  %
  % :returns: - :filename: (string)
  %
  %

  % (C) Copyright 2022 bidspm developers

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
