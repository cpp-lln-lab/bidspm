function rfxDir = getRFXdir(varargin)
  %
  % Sets the name the group level analysis directory and creates it if it does not exist
  %
  % USAGE::
  %
  %   rfxDir = getRFXdir(opt, nodeName, contrastName, thisGroup)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :param nodeName:
  % :type nodeName: char
  %
  % :param contrastName:
  % :type contrastName: char
  %
  % :param thisGroup:
  % :type thisGroup: cellstr
  %
  % :return: rfxDir: (string) Fullpath of the group level directory
  %
  % Typical output:
  %
  % - ``opt.dir.derivatives/bidspm-stats/derivatives/bidspm-groupStats/bidspm-stats``
  %
  % .. code-block:: matlab
  %
  %   ['sub-ALL-task-',     model.Input.task, ...
  %    '_space-'    model.Input.space, ...
  %    '_FWHM-',    num2str(opt.fwhm.func), ...
  %    '_conFWHM-', opt.fwhm.contrast, ...
  %    'node-', model.Input.Nodes(dataset_level).Name, ...             % optional
  %    'contrast-', model.Input.Nodes(dataset_level).Contrast(i).Name  % if ~= from "dataset_level"
  %    ]
  %

  % (C) Copyright 2019 bidspm developers

  args = inputParser;

  args.addRequired('opt', @isstruct);
  args.addOptional('nodeName', '', @ischar);
  args.addOptional('contrastName', '', @ischar);
  args.addOptional('thisGroup', '', @ischar);

  args.parse(varargin{:});

  opt =  args.Results.opt;
  nodeName =  args.Results.nodeName;
  contrastName =  args.Results.contrastName;
  thisGroup =  args.Results.thisGroup;

  %%
  glmDirName = createGlmDirName(opt);

  glmDirName = [glmDirName, '_conFWHM-', num2str(opt.fwhm.contrast)];

  if ~isempty(nodeName) && ~strcmpi(nodeName, 'dataset_level')
    glmDirName = [glmDirName, '_node-', bids.internal.camel_case(nodeName)];
  end

  if ~isempty(contrastName) && ~strcmpi(contrastName, 'dataset_level')
    glmDirName = [glmDirName, '_contrast-', bids.internal.camel_case(contrastName)];
  end

  sub = 'ALL';
  if ~isempty(contrastName)
    participants = bids.util.tsvread(fullfile(opt.dir.raw, 'participants.tsv'));
    groupColumnHdr = opt.model.bm.getGroupColumnHdrFromGroupBy(nodeName, participants);
    if ~isempty(groupColumnHdr) && ~isempty(thisGroup)
      sub = thisGroup;
    end
  end

  glmDirName = ['sub-', sub, '_', glmDirName];

  rfxDir = fullfile(opt.dir.stats, ...
                    'derivatives', ...
                    'bidspm-groupStats', ...
                    glmDirName);

  spm_mkdir(rfxDir);

end
